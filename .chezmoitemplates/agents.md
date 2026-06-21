# 開発スタイル

TDD で開発する（探索 → Red → Green → Refactoring）。
不明瞭な指示は質問して明確にする。
コミットメッセージは Conventional Commits に従う。

# 言語ガイドライン

常に日本語で会話する

# コード設計

- 関心の分離を保つ
- 状態とロジックを分離する
- 可読性と保守性を重視する
- コントラクト層（API/型）を厳密に定義し、実装層は再生成可能に保つ
- 静的検査可能なルールはプロンプトではなく、その環境の linter か ast-grep で記述する

# ツール

- タスク: justfile 。Makefile しか無い既存 repo はそのまま尊重し、無理に置き換えない。新規 repo・自分の repo は justfile を第一候補にする
- Node.js: pnpm, v24+
- E2E: playwright

# 環境

- GitHub: {{ .github_username }}
- リポジトリ: ghq 管理（`~/src/github.com/owner/repo`）

# 破壊的操作

- ツール（home-manager / brew / chezmoi / pre-commit / pip / npm 等）が auto-rename した `*.backup` / `*.orig` / `*.pre-*` 系を `rm` する前に、内容を `cat` して会話に出すか別ファイルに dump する。最低 1 回の表示を経てから削除する
  （理由: 自分が作ったファイルではないので、消すと「元に何が入っていたか」が永久に失われる。`/etc/zshenv` のような system-level 置き土産が紛れていても気づけなくなる）

# スキル作成

新規 skill を作るとき、配置先を次の指針で決める:

- **project 固有** (`<repo>/.claude/skills/` に置く / 該当 repo の `apm.yml` で配布): 特定 repo のドメイン知識・規約・ファイルレイアウトに依存し、他 repo で使う見込みがない
- **グローバル** (`~/.claude/skills/` 直置き or APM global): 言語・ツール横断、複数 repo で再利用可能、運用ノウハウ
- **判断不能なとき**: ユーザーに「project 固有かグローバルか」を質問してから作成（理由: 後から移動するとパス参照や apm.yml 設定が壊れやすい）

# 並列化と subagent

タスクを受けたら最初に「**並列化できる subtask は何か**」「**subagent に投げて main context を空けられるか**」を洗い出してから動く。default は subagent 優先 / 並列優先。

判断:

- **互いに独立な 2+ task**: Agent tool で 1 message 内に並列 dispatch (independent search、 multi-scenario eval、 multi-model 比較など)
- **大量探索・grep・解析 (3+ query 規模)**: `general-purpose` / `Explore` subagent に投げ、 main は要約だけ受け取る
- **bias-free 評価** (skill / prompt / 自分の生成物の検証): 新規 subagent。 「自分で再読」 は禁じ手 (`empirical-prompt-tuning` の caveat 通り)
- **Long-running batch** (Bash の 10 分上限を超える / `apm install` を多 repo に回す等): subagent dispatch か `run_in_background` + `Monitor`

避けるべき:

- 直列依存 (前 task の結果が次 task 入力) を無理に並列化する
- 1-step / short lookup を subagent に投げる (overhead がコストに見合わない)
- subagent と main で同じ作業を二重で走らせる

# モデルコスト配分 （サブエージェント委譲）

メインセッションが高コストモデル（Fable / Opus）のとき、トークン消費を抑えるため次のように使い分ける:

- メインセッションは設計・タスク分割・監査・レビューを担う
- 実装の使い分け: 小規模な修正・テスト作成・機械的な変更は `implementer` agent（Sonnet）に切り出す。大規模・難易度の高い実装（横断的な変更、繊細なリファクタリング、根本原因不明のデバッグ）はメインセッション（Fable 1M）が直接行う
- 戻りの大きい MCP 呼び出し（Google Drive 等のファイル内容取得、大量の検索結果）は `mcp-fetcher` agent（Sonnet・読み取り専用）で実行し、要約・抽出結果だけをメインに返す。メインのコンテキストに生データを流さない
- 読み取り専用の広い探索（コードベース調査など）はビルトインの `Explore` agent に切り出してメインのコンテキストを節約する
- 委譲するときは自己完結したプロンプトを渡す（対象ファイルパス・従うべき規約・完了条件・検証コマンドを含める）
- subagent は非同期でディスパッチし、返るまでブロックせずメインは並行して作業を続ける
- 長時間タスクでは自己批評でなく、新しいコンテキストを持つ独立 subagent に仕様照合の検証を定期的にさせる
- subagent の成果物はメインセッションが必ずレビュー・検証してから完了とする
