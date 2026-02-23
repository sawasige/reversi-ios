# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Reversi (Othello) iOS app with online multiplayer ambitions. Currently implements Phase 1 (local play) and Phase 2 (AI play) of the development roadmap. Built with SwiftUI targeting iOS 17+.

## Build & Test Commands

```bash
# Build
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'generic/platform=iOS Simulator' build

# Run all tests
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test

# Run a single test class
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test -only-testing:ReversiOnlineTests/BoardTests

# Run a single test method
xcodebuild -project ReversiOnline.xcodeproj -scheme ReversiOnline -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test -only-testing:ReversiOnlineTests/BoardTests/testPlaceDisk
```

## Architecture

**MVVM pattern** with SwiftUI.

### Models (`ReversiOnline/Models/`)
- `Disk` — enum (`.dark`/`.light`) representing piece color. `.dark` is always first player.
- `Position` — (row, col) coordinate on the 8x8 board. `Direction` defines the 8 movement vectors.
- `Board` — value type holding the 8x8 `[[Disk?]]` grid. Contains all game rules: valid move detection via `flippableDisks(for:at:)`, placement via `place(disk:at:)`, game-over detection. The subscript is read-only externally; mutations go through `place()`.
- `GameMode` — `.local` or `.ai(AIDifficulty)`. Future phases add online modes.

### AI (`ReversiOnline/AI/`)
- `AIPlayer` — `Sendable` class implementing Minimax with alpha-beta pruning. Three difficulty levels control search depth (1/4/6). Evaluation uses position weights (corners=100, X-squares=-50), mobility, and endgame piece counting. Called on a detached Task to avoid blocking UI.

### ViewModel (`ReversiOnline/ViewModels/`)
- `GameViewModel` — `@MainActor ObservableObject` managing turn flow, AI triggering, pass detection, and game-over. Publishes `board`, `currentTurn`, `validMoves`, `phase`, `lastMove`, and `message`. The `isAnimating` flag gates input during flip animations.

### Views (`ReversiOnline/Views/`)
- `HomeView` → `GameView` via NavigationStack with `navigationDestination(item:)`.
- `BoardView` renders the 8x8 grid using GeometryReader for sizing.
- `CellView` shows valid-move indicators and last-move highlights. Uses `.id(disk)` to trigger SwiftUI transitions on piece flips.
- `PieceView` animates with `rotation3DEffect` and spring scale on appear.
- `ScoreView` / `PlayerScoreView` show piece counts with numeric transitions.

### Services (`ReversiOnline/Services/`)
- `SoundManager` — singleton stub for AVAudioPlayer-based SE playback. Sound files not yet included.

## Key Design Decisions

- `Board` is a **value type** (struct) for easy AI tree search (copy-on-write).
- AI runs on `Task.detached` to keep the main actor responsive.
- Deployment target iOS 17.0 enables `navigationDestination(item:)` and `contentTransition(.numericText())`.
- The Xcode project uses `GENERATE_INFOPLIST_FILE = YES` (no separate Info.plist).

## Development Roadmap (from spec)

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | Done | Local play — board UI, game logic, basic navigation |
| 2 | Done | AI play — Minimax + alpha-beta, difficulty selection |
| 3 | TODO | 3D animations + sound effects |
| 4 | TODO | Online play — Firebase Auth/Firestore/Cloud Functions |
| 5 | TODO | Rating & rank system (Elo/Glicko) |
| 6 | TODO | Points, missions, skins, season pass |
| 7 | TODO | Social — spectating, replays, guilds |
| 8 | TODO | Statistics, game analysis, monetization |
