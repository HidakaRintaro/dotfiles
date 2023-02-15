# Warp
設定ファイル類があるわけではないが、設定ファイルがどこにあるかわからないためフォントや文字サイズなどを記載。  
> **Note**
> `workflows`, `launch_configurations`のファイルを用意する場合は`.warp`ファイルを作成しシンボリックリンクを作成する

## 公式
https://www.warp.dev/

## Font
フォントは`Hack Nerd Font`に設定する。  
他のフォントを使用する場合はStarshipで使用しているアイコンを表示できるものにする。

## Prompt
Starshipのプロンプトを使用できるように必ず設定する。  
`Settings > Features > Session`へ行き、`Honor user's custom prompt`をONにする。  
または、プロンプトを右クリックし`Use my own prompt`をクリックでも同様のことができる。


## Settings
### Appearance
#### Themes
| 設定項目 | 設定内容 |
|:---:|:---:|
| Sync with OS <br> OSと同期するか | OFF |
| Current theme <br> ターミナルのテーマ | Willow Dream |
| Window Opacity <br> 透明度 | 80 |
| Window Blur Radius <br> ぼかし | 10 |

#### Panes
| 設定項目 | 設定内容 |
|:---:|:---:|
| Dim inactive panes <br> 非アクティブなペインを減光するか | ON |

#### Blocks
| 設定項目 | 設定内容 |
|:---:|:---:|
| Compact mode | OFF |

#### Text
fontは`View all available system fonts`にチェックを入れないと選択できません。

| 設定項目 | 設定内容 |
|:---:|:---:|
| Terminal font | Hack Nerd Font |
| Font size | 16 |
| Line height | 1.2 |
| Use thin strokes | On low-DPI displays |
| Enforce minimum contrast | Never |

#### Cursor
| 設定項目 | 設定内容 |
|:---:|:---:|
| Blinking cursor | ON |

### Features
デフォルトの設定と違うところのみ記載。

#### General
| 設定項目 | 設定内容 |
|:---:|:---:|
| Copy on select | OFF |

#### Session 
| 設定項目 | 設定内容 |
|:---:|:---:|
| Honor user's custom prompt <br> カスタムプロンプトを使用するか | ON |
| Receive desktop notifications from Warp | OFF |

#### Key
| 設定項目 | 設定内容 |
|:---:|:---:|
| Hotkey Window | ON |
| Keybinding | `⌥` + `Space` <br> Pin to bottom <br> Active Screen <br> w:100%, h:30% <br> Autohides on loss of keyboard focus: ON |

### Privacy
| 設定項目 | 設定内容 |
|:---:|:---:|
| Send app analytics | OFF |