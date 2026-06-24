#!/bin/bash
# Claude Code statusline - chezmoi 管理
#
# 表示レイアウト:
#   行1: [フォルダ] ディレクトリ [| [GitHub] owner/repo] | [ブランチ] ブランチ名 コンフリクト +staged ~unstaged ?untracked ⇡ahead⇣behind | PR #番号 | [ツリー] worktree名
#   行2: [ロボット] モデル | [ゲージ] effort | [ステータス] OK/DEGRADED/DOWN | [円] 金額(session) | [円] 金額(daily) | [円] 金額(weekly)
#   行3: ctx ○% | [時計] 5h [バー] % HH:MM | [カレンダー] 7d [バー] % M/D HH:MM
#
# 為替レート(frankfurter.dev)の取得部はコメントアウト済み。
# 有効化するときは usd_jpy_rate 関数のコメントを参照。

# mise の PATH を補完（mise シェル外から起動された場合に bun/ccusage を解決するため）
[ -n "$MISE_SHELL" ] || export PATH="$HOME/.local/share/mise/shims:$PATH"

input=$(cat)

# JSON フィールドを一括取得。フィールド区切りに \x1f (Unit Separator) を使用して
# タブ・改行との衝突を回避する
IFS=$'\x1f' read -r model effort cwd project wt \
  ctx_pct cost_usd \
  fh_pct fh_reset \
  sd_pct sd_reset \
  pr_num pr_url \
  session_id \
  < <(echo "$input" | jq -r '[
  (.model.display_name // "Claude"),
  (.effort.level // ""),
  (.workspace.current_dir // .cwd // ""),
  (.workspace.project_dir // ""),
  (.workspace.git_worktree // ""),
  (.context_window.used_percentage // ""),
  (.cost.total_cost_usd // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (if .pr.number then (.pr.number | tostring) else "" end),
  (.pr.url // ""),
  (.session_id // "")
] | join("")')

# ── カラーパレット (True Color / 24bit RGB) ────────────────────────────────────
# セマンティックな役割で定義し、用途ごとに使い分ける
RST=$'\033[0m'
DIM=$'\033[2m'
C_OK=$'\033[38;2;78;201;148m'       # #4EC994 緑  - 正常 (staged, ● OK)
C_WARN=$'\033[38;2;226;181;106m'    # #E2B56A 黄  - 警告 (unstaged)
C_DANGER=$'\033[38;2;224;108;117m'  # #E06C75 赤  - 危険 (コンフリクト)
C_INFO=$'\033[38;2;97;175;239m'     # #61AFEF 青  - 情報 (ディレクトリ, ahead/behind)
C_ACCENT=$'\033[38;2;198;120;221m'  # #C678DD 紫  - 強調 (ブランチ名)

SEP="${DIM} | ${RST}"

# ── Nerd Font アイコン (Hack Nerd Font, raw UTF-8 バイト列) ───────────────────
I_DIR=$'\xef\x81\xbb'        # nf-fa-folder        U+F07B
I_BRANCH=$'\xf3\xb0\x98\xac' # nf-md-source_branch U+F062C
I_WT=$'\xf3\xb0\x99\x85'     # nf-md-file_tree     U+F0645
I_MODEL=$'\xf3\xb0\x9a\xa9'  # nf-md-robot         U+F06A9
I_EFFORT=$'\xef\x83\xa4'     # nf-fa-tachometer    U+F0E4
I_5H=$'\xef\x80\x97'         # nf-fa-clock_o       U+F017
I_7D=$'\xef\x81\xb3'         # nf-fa-calendar      U+F073
I_COST=$'\xef\x85\x97'       # nf-fa-yen           U+F157
I_CONFLICT=$'\xef\x81\xb1'   # nf-fa-warning       U+F071
I_STATUS_OK=$'\xf3\xb0\x97\xa1'   # nf-md-check_circle_outline U+F05E1
I_STATUS_WARN=$'\xf3\xb0\x97\x96' # nf-md-alert_circle_outline U+F05D6
I_STATUS_DOWN=$'\xf3\xb0\x85\x9a' # nf-md-close_circle_outline U+F015A
I_RETRY=$'\xef\x80\xa1'      # nf-fa-refresh       U+F021
I_GITHUB=$'\xee\x9c\x89'     # nf-dev-github       U+E709

# ── キャッシュ設定 ─────────────────────────────────────────────────────────────
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
mkdir -p "$CACHE_DIR" 2>/dev/null && chmod 700 "$CACHE_DIR" 2>/dev/null

# ファイルの最終更新時刻を Unix epoch 秒で返す
file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

# Unix epoch を日本時間 (JST) に変換して指定フォーマットで出力
fmt_epoch_jst() {
  TZ=Asia/Tokyo date -r "$1" "+$2" 2>/dev/null || \
  TZ=Asia/Tokyo date -d "@$1" "+$2" 2>/dev/null
}

# ── Ring Meter ────────────────────────────────────────────────────────────────
# 5段階の円形文字で使用率を1文字で表現する
RINGS=('○' '◔' '◑' '◕' '●')

# ring_meter <使用率%>
# 使用率に応じた3段階カラー（緑/黄/赤）付きのリングメーターを出力する
ring_meter() {
  local pct=${1%%.*} idx color

  [ -z "$pct" ] && pct=0

  # 0-24%: ○  25-49%: ◔  50-74%: ◑  75-99%: ◕  100%: ●
  idx=$(( pct >= 100 ? 4 : pct / 25 ))

  # 3段階: ~60% 緑、~80% 黄、81%~ 赤
  if   [ "$pct" -le 60 ]; then color="$C_OK"
  elif [ "$pct" -le 80 ]; then color="$C_WARN"
  else                          color="$C_DANGER"
  fi

  printf '%s%s%s' "$color" "${RINGS[$idx]}" "$RST"
}

# ── Fine Bar ──────────────────────────────────────────────────────────────────
# Unicode ブロック文字 8段階で1文字あたり1/8刻みの精度を実現
BLOCKS=(' ' '▏' '▎' '▍' '▌' '▋' '▊' '▉' '█')

# progress_bar <使用率%> [バー幅=10]
# 使用率に応じた3段階カラー（緑/黄/赤）付きのプログレスバーを出力する
progress_bar() {
  local pct=${1%%.*} width=${2:-10}
  local filled_f full frac bar i empty color

  [ -z "$pct" ] && pct=0

  filled_f=$(awk -v p="$pct" -v w="$width" 'BEGIN{printf "%.6f", p*w/100}')
  full=$(awk -v f="$filled_f" 'BEGIN{printf "%d", int(f)}')
  frac=$(awk -v f="$filled_f" -v fi="$full" 'BEGIN{printf "%d", int((f-fi)*8)}')

  # 3段階: ~60% 緑、~80% 黄、81%~ 赤
  if   [ "$pct" -le 60 ]; then color="$C_OK"
  elif [ "$pct" -le 80 ]; then color="$C_WARN"
  else                          color="$C_DANGER"
  fi

  bar=""
  for ((i = 0; i < full; i++)); do bar+='█'; done
  if [ "$full" -lt "$width" ]; then
    bar+="${BLOCKS[$frac]}"
    empty=$((width - full - 1))
    for ((i = 0; i < empty; i++)); do bar+='░'; done
  fi

  printf '%s%s%s' "$color" "$bar" "$RST"
}

# ── 為替レート (USD→JPY) ──────────────────────────────────────────────────────
# 有効化時: 下記関数のコメントアウトを外し、JPY_RATE=160 の行を削除する
# frankfurter.dev API を使用（日次キャッシュ、24時間 TTL）
#
# usd_jpy_rate() {
#   local cache="$CACHE_DIR/usdjpy"
#   local now mtime
#   now=$(date +%s)
#   mtime=$(file_mtime "$cache")
#   if [ $((now - mtime)) -gt 86400 ]; then
#     touch "$cache"
#     (curl -s --max-time 3 \
#       "https://api.frankfurter.dev/v1/latest?base=USD&symbols=JPY" 2>/dev/null |
#       jq -r '.rates.JPY // empty' >"$cache.tmp" \
#       && [ -s "$cache.tmp" ] && mv "$cache.tmp" "$cache") &
#   fi
#   cat "$cache" 2>/dev/null
# }
# JPY_RATE=$(usd_jpy_rate)
JPY_RATE=160  # 固定値（有効化時は上記関数に置き換える）

# USD を円換算してカンマ区切りで出力（例: ¥1,204）
fmt_jpy() {
  local usd="$1"
  [ -z "$usd" ] && return
  local jpy
  jpy=$(awk -v u="$usd" -v r="$JPY_RATE" 'BEGIN{printf "%d", int(u*r+0.5)}')
  [ "$jpy" = "0" ] && return
  echo "$(echo "$jpy" | rev | sed 's/[0-9][0-9][0-9]/&,/g' | rev | sed 's/^,//')"
}

# ── 1日のコスト (ccusage, 5分キャッシュ) ─────────────────────────────────────
daily_cost() {
  local cache="$CACHE_DIR/daily_$(date +%Y%m%d)"
  local now mtime
  now=$(date +%s)
  mtime=$(file_mtime "$cache")
  if [ $((now - mtime)) -gt 300 ]; then
    touch "$cache"
    (ccusage daily --since "$(date +%Y%m%d)" --json 2>/dev/null |
      jq -r '.totals.totalCost // empty' >"$cache.tmp" \
      && mv "$cache.tmp" "$cache") &
  fi
  cat "$cache" 2>/dev/null
}

# ── 7日間のコスト (ccusage, 5分キャッシュ) ───────────────────────────────────
weekly_cost() {
  local cache="$CACHE_DIR/weekly_$(date +%Y%m%d)"
  local now mtime
  now=$(date +%s)
  mtime=$(file_mtime "$cache")
  if [ $((now - mtime)) -gt 300 ]; then
    touch "$cache"
    (ccusage weekly --json 2>/dev/null |
      jq -r '.totals.totalCost // empty' >"$cache.tmp" \
      && mv "$cache.tmp" "$cache") &
  fi
  cat "$cache" 2>/dev/null
}

# ── Git 情報 (session_id 別 5秒キャッシュ) ───────────────────────────────────
GIT_CACHE="$CACHE_DIR/git-${session_id:-nosession}"
now_ts=$(date +%s)
git_mtime=$(file_mtime "$GIT_CACHE")

if [ $((now_ts - git_mtime)) -gt 5 ]; then
  git_dir="${cwd:-$(pwd)}"
  if git -C "$git_dir" --no-optional-locks rev-parse --is-inside-work-tree \
      >/dev/null 2>&1; then

    branch=$(git -C "$git_dir" --no-optional-locks branch --show-current 2>/dev/null)
    git_out=$(git -C "$git_dir" --no-optional-locks status --porcelain 2>/dev/null)

    # ステータス別にファイル数を集計
    # grep -c はマッチゼロでも stdout に "0" を出して exit 1 を返すため
    # `|| echo 0` と組み合わせると "0\n0" になりキャッシュに \n が埋め込まれる
    conflicts=$(echo "$git_out" | grep -cE '^(UU|AA|DD|AU|UA|DU|UD)' 2>/dev/null); conflicts=${conflicts:-0}
    staged=$(echo "$git_out"    | grep -cE '^[MADRCT]'                2>/dev/null); staged=${staged:-0}
    unstaged=$(echo "$git_out"  | grep -cE '^.[MDRCT]'                2>/dev/null); unstaged=${unstaged:-0}
    untracked=$(echo "$git_out" | grep -c  '^??'                      2>/dev/null); untracked=${untracked:-0}

    # upstream との ahead/behind コミット数
    read -r behind ahead < <(
      git -C "$git_dir" --no-optional-locks \
        rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null
    )

    # GitHub の owner/repo を origin remote URL から抽出
    # HTTPS: https://github.com/owner/repo.git  SSH: git@github.com:owner/repo.git
    remote_url=$(git -C "$git_dir" --no-optional-locks remote get-url origin 2>/dev/null)
    remote_slug=""
    if [[ "$remote_url" =~ github\.com[:/]([^/]+/[^/.]+)(\.git)?$ ]]; then
      remote_slug="${BASH_REMATCH[1]}"
    fi

    printf '%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s' \
      "${branch}" \
      "${conflicts:-0}" "${staged:-0}" "${unstaged:-0}" "${untracked:-0}" \
      "${behind:-0}" "${ahead:-0}" \
      "${remote_slug}" \
      > "$GIT_CACHE"
  else
    # Git リポジトリ外: 空エントリを書き込んでキャッシュを更新
    printf '\x1f0\x1f0\x1f0\x1f0\x1f0\x1f0\x1f' > "$GIT_CACHE"
  fi
fi

IFS=$'\x1f' read -r \
  git_branch git_conflicts git_staged git_unstaged git_untracked \
  git_behind git_ahead git_remote_slug \
  < "$GIT_CACHE" 2>/dev/null

# ── 行1: ディレクトリ | Git 情報 | worktree ──────────────────────────────────
# プロジェクトルート配下にいる場合は「プロジェクト名/相対パス」形式で表示
if [ -n "$project" ] && [ -n "$cwd" ] && [ "$cwd" != "$project" ]; then
  case "$cwd" in
    "$project"/*) dir_display="$(basename "$project")/${cwd#"$project"/}" ;;
    *)            dir_display=$(basename "$cwd") ;;
  esac
else
  dir_display=$(basename "${cwd:-$(pwd)}")
fi

line1="${I_DIR} ${C_INFO}${dir_display}${RST}"

# ローカルパスが ghq 規則 (~/src/github.com/owner/repo) と異なる場合に GitHub slug を表示
if [ -n "$git_remote_slug" ]; then
  expected_path="$HOME/src/github.com/${git_remote_slug}"
  if [ "${project:-$cwd}" != "$expected_path" ]; then
    line1+="${SEP}${I_GITHUB} $(printf '\033]8;;https://github.com/%s\a%s\033]8;;\a' "$git_remote_slug" "$git_remote_slug")"
  fi
fi

if [ -n "$git_branch" ]; then
  git_seg="${C_ACCENT}${I_BRANCH} ${git_branch}${RST}"
  [ "${git_conflicts:-0}" -gt 0 ] && git_seg+=" ${C_DANGER}${I_CONFLICT}${git_conflicts}${RST}"
  [ "${git_staged:-0}"    -gt 0 ] && git_seg+=" ${C_OK}+${git_staged}${RST}"
  [ "${git_unstaged:-0}"  -gt 0 ] && git_seg+=" ${C_WARN}~${git_unstaged}${RST}"
  [ "${git_untracked:-0}" -gt 0 ] && git_seg+=" ${DIM}?${git_untracked}${RST}"
  [ "${git_ahead:-0}"     -gt 0 ] && git_seg+=" ${C_INFO}⇡${git_ahead}${RST}"
  [ "${git_behind:-0}"    -gt 0 ] && git_seg+=" ${C_INFO}⇣${git_behind}${RST}"
  line1+="${SEP}${git_seg}"
fi

# PR 番号（URL がある場合は OSC 8 でクリッカブルリンクにする）
if [ -n "$pr_num" ] && [ "$pr_num" != "0" ]; then
  if [ -n "$pr_url" ]; then
    pr_seg="$(printf '\033]8;;%s\aPR #%s\033]8;;\a' "$pr_url" "$pr_num")"
  else
    pr_seg="PR #${pr_num}"
  fi
  line1+="${SEP}${pr_seg}"
fi

[ -n "$wt" ] && line1+="${SEP}${I_WT} ${wt}"

printf '%s\n' "$line1"

# ── 行2: モデル | effort | ステータス | コスト ──────────────────────────────
line2="${I_MODEL} ${model}"

[ -n "$effort" ] && line2+="${SEP}${I_EFFORT} ${effort}"

# Claude サービスステータス
# 有効化時: status.claude.com API を実装し、状態に応じて
#   OK → ${C_OK}${I_STATUS_OK}  DEGRADED → ${C_WARN}${I_STATUS_WARN}  DOWN → ${C_DANGER}${I_STATUS_DOWN}
line2+="${SEP}${C_OK}$(printf '\033]8;;https://status.claude.com\a%s OK\033]8;;\a' "${I_STATUS_OK}")${RST}"

# セッションコスト（JSON から取得、固定レートで円換算）
session_cost=$(fmt_jpy "$cost_usd")
[ -n "$session_cost" ] && line2+="${SEP}${I_COST}${session_cost}${DIM}(session)${RST}"

# 1日のコスト
daily=$(fmt_jpy "$(daily_cost)")
[ -n "$daily" ] && line2+="${SEP}${I_COST}${daily}${DIM}(daily)${RST}"

# 7日間のコスト
weekly=$(fmt_jpy "$(weekly_cost)")
[ -n "$weekly" ] && line2+="${SEP}${I_COST}${weekly}${DIM}(weekly)${RST}"

printf '%s\n' "$line2"

# ── 行3: ctx リングメーター | 5時間レートバー | 7日間レートバー ───────────────
line3=""

# コンテキスト使用率 (Ring Meter)
if [ -n "$ctx_pct" ]; then
  ctx_int=${ctx_pct%%.*}
  line3+="ctx $(ring_meter "$ctx_int") ${ctx_int}%"
fi

# 5時間レート制限バー
if [ -n "$fh_pct" ]; then
  fh_int=${fh_pct%%.*}
  seg="${I_5H} 5h $(progress_bar "$fh_int" 10) ${fh_int}%"
  if [ -n "$fh_reset" ] && [ "$fh_reset" != "0" ]; then
    seg+=" ${DIM}${I_RETRY}$(fmt_epoch_jst "$fh_reset" '%H:%M')${RST}"
  fi
  line3+="${SEP}${seg}"
fi

# 7日間レート制限バー
if [ -n "$sd_pct" ]; then
  sd_int=${sd_pct%%.*}
  seg="${I_7D} 7d $(progress_bar "$sd_int" 10) ${sd_int}%"
  if [ -n "$sd_reset" ] && [ "$sd_reset" != "0" ]; then
    seg+=" ${DIM}${I_RETRY}$(fmt_epoch_jst "$sd_reset" '%m/%d %H:%M')${RST}"
  fi
  line3+="${SEP}${seg}"
fi

[ -n "$line3" ] && printf '%s\n' "$line3"
