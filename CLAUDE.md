# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイドです。

## プロジェクト概要

リバーシ（オセロ）のiOSアプリ。オンライン対戦を見据えた設計。現在はPhase 1（ローカル対戦）とPhase 2（AI対戦）を実装済み。SwiftUI + iOS 17+。

## ビルド・テストコマンド

```bash
# ビルド
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'generic/platform=iOS Simulator' build

# 全テスト実行
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test

# 特定のテストクラスのみ実行
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test -only-testing:ReversiOnlineTests/BoardTests

# 特定のテストメソッドのみ実行
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test -only-testing:ReversiOnlineTests/BoardTests/testPlaceDisk
```

## アーキテクチャ

**MVVM** パターン + SwiftUI。

### Models (`ReversiOnline/Models/`)
- `Disk` — 石の色を表すenum（`.dark`/`.light`）。`.dark`が常に先手。
- `Position` — 8×8盤面上の(row, col)座標。`Direction`で8方向の移動ベクトルを定義。
- `Board` — 8×8の`[[Disk?]]`グリッドを持つ値型。合法手判定（`flippableDisks(for:at:)`）、石の配置（`place(disk:at:)`）、終局判定を含む。外部からのsubscriptは読み取り専用で、変更は`place()`経由。
- `GameMode` — `.local`または`.ai(AIDifficulty)`。将来フェーズでオンラインモードを追加。

### AI (`ReversiOnline/AI/`)
- `AIPlayer` — Minimax + α-β枝刈りを実装した`Sendable`クラス。難易度3段階で探索深さを制御（1/4/6）。評価関数は位置重み（角=100, X打ち=-50）、機動力、終盤の石数を考慮。`Task.detached`でUI非ブロッキング実行。

### ViewModel (`ReversiOnline/ViewModels/`)
- `GameViewModel` — `@MainActor ObservableObject`。ターン管理、AI呼び出し、パス判定、終局処理を担当。`board`、`currentTurn`、`validMoves`、`phase`、`lastMove`、`message`を公開。`isAnimating`フラグで反転アニメーション中の入力を制御。

### Views (`ReversiOnline/Views/`)
- `HomeView` → `GameView`：NavigationStackの`navigationDestination(item:)`で遷移。
- `BoardView`：GeometryReaderで8×8グリッドをサイズ調整して描画。
- `CellView`：合法手インジケーターと最終手ハイライトを表示。`.id(disk)`でSwiftUIトランジションを発火。
- `PieceView`：`rotation3DEffect`とスプリングスケールでアニメーション。
- `ScoreView` / `PlayerScoreView`：数値トランジション付きの石数表示。

### Services (`ReversiOnline/Services/`)
- `SoundManager` — AVAudioPlayerベースのSE再生シングルトン（スタブ）。音声ファイルは未同梱。

## 設計上の判断

- `Board`は**値型**（struct）。AI探索時のコピーが容易（copy-on-write）。
- AIは`Task.detached`で実行し、メインアクターをブロックしない。
- デプロイターゲットiOS 17.0で`navigationDestination(item:)`や`contentTransition(.numericText())`を使用。
- Xcodeプロジェクトは`GENERATE_INFOPLIST_FILE = YES`（Info.plistファイル不要）。
- フォルダベース管理（`PBXFileSystemSynchronizedRootGroup`、objectVersion 77）。ファイル追加時にpbxprojの変更不要。

## 開発ロードマップ

| Phase | 状態 | 内容 |
|-------|------|------|
| 1 | 完了 | ローカル対戦 — 盤面UI、ゲームロジック、基本ナビゲーション |
| 2 | 完了 | AI対戦 — Minimax + α-β枝刈り、難易度選択 |
| 3 | 未着手 | 3Dアニメーション + 効果音 |
| 4 | 未着手 | オンライン対戦 — Firebase Auth/Firestore/Cloud Functions |
| 5 | 未着手 | レーティング・ランクシステム（Elo/Glicko） |
| 6 | 未着手 | ポイント、ミッション、スキン、シーズンパス |
| 7 | 未着手 | ソーシャル機能 — 観戦、リプレイ、ギルド |
| 8 | 未着手 | 統計、棋譜分析、収益化 |
