import Foundation
import SwiftUI

enum GamePhase: Equatable {
    case playing
    case gameOver
}

struct GameResult: Equatable {
    let darkCount: Int
    let lightCount: Int

    var winner: Disk? {
        if darkCount > lightCount { return .dark }
        if lightCount > darkCount { return .light }
        return nil
    }

    var isDraw: Bool { darkCount == lightCount }
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published var board: Board
    @Published var currentTurn: Disk
    @Published var phase: GamePhase
    @Published var validMoves: [Position]
    @Published var lastMove: Position?
    @Published var message: String
    @Published var isAnimating: Bool
    @Published var flippingDisks: [Position: Double] = [:]

    let gameMode: GameMode
    private var aiPlayer: AIPlayer?

    var darkCount: Int { board.count(of: .dark) }
    var lightCount: Int { board.count(of: .light) }

    var result: GameResult? {
        guard phase == .gameOver else { return nil }
        return GameResult(darkCount: darkCount, lightCount: lightCount)
    }

    init(mode: GameMode) {
        self.gameMode = mode
        self.board = Board()
        self.currentTurn = .dark
        self.phase = .playing
        self.validMoves = []
        self.lastMove = nil
        self.message = "黒の番です"
        self.isAnimating = false

        switch mode {
        case .ai(let difficulty):
            self.aiPlayer = AIPlayer(difficulty: difficulty)
        default:
            self.aiPlayer = nil
        }

        updateValidMoves()
    }

    func placeDisk(at position: Position) {
        guard phase == .playing,
              !isAnimating,
              board.canPlace(disk: currentTurn, at: position) else { return }

        if case .ai = gameMode, currentTurn == .light {
            return
        }

        executePlacement(at: position)
    }

    func restart() {
        board = Board()
        currentTurn = .dark
        phase = .playing
        lastMove = nil
        message = "黒の番です"
        isAnimating = false
        flippingDisks = [:]
        updateValidMoves()
    }

    // MARK: - Private

    private func executePlacement(at position: Position) {
        isAnimating = true
        lastMove = position
        let flipped = board.place(disk: currentTurn, at: position)

        // Play placement sound
        SoundManager.shared.playPlaceSound()

        // Calculate wave delays based on distance from placement position
        var delays: [Position: Double] = [:]
        let sortedFlips = flipped.sorted { a, b in
            let distA = (a.row - position.row) * (a.row - position.row)
                + (a.col - position.col) * (a.col - position.col)
            let distB = (b.row - position.row) * (b.row - position.row)
                + (b.col - position.col) * (b.col - position.col)
            return distA < distB
        }
        for (index, pos) in sortedFlips.enumerated() {
            delays[pos] = Double(index) * 0.08
        }
        flippingDisks = delays

        // Play flip sound
        if !flipped.isEmpty {
            SoundManager.shared.playFlipSound()
        }

        // Wait for all animations to complete
        let maxDelay = delays.values.max() ?? 0
        let totalAnimDuration = maxDelay + 0.5 // max delay + flip animation (0.4s) + buffer

        Task {
            try? await Task.sleep(for: .seconds(totalAnimDuration))
            self.flippingDisks = [:]
            self.isAnimating = false
            self.advanceTurn()
        }
    }

    private func advanceTurn() {
        let nextDisk = currentTurn.flipped

        if !board.validMoves(for: nextDisk).isEmpty {
            currentTurn = nextDisk
            message = "\(currentTurn.name)の番です"
            updateValidMoves()
        } else if !board.validMoves(for: currentTurn).isEmpty {
            message = "\(nextDisk.name)はパスです"
            SoundManager.shared.playPassSound()
            updateValidMoves()
        } else {
            endGame()
            return
        }

        if case .ai = gameMode, currentTurn == .light, phase == .playing {
            triggerAIMove()
        }
    }

    private func triggerAIMove() {
        guard let aiPlayer = aiPlayer else { return }

        message = "CPU思考中..."
        validMoves = []

        Task {
            try? await Task.sleep(for: .seconds(0.4))

            let move = await Task.detached { [board, currentTurn] in
                aiPlayer.bestMove(board: board, for: currentTurn)
            }.value

            if let move = move {
                self.executePlacement(at: move)
            }
        }
    }

    private func endGame() {
        phase = .gameOver
        validMoves = []

        let gameResult = GameResult(darkCount: darkCount, lightCount: lightCount)
        if let winner = gameResult.winner {
            message = "\(winner.name)の勝ち！ (\(darkCount) - \(lightCount))"
            if case .ai = gameMode {
                SoundManager.shared.playGameOverSound(won: winner == .dark)
            } else {
                SoundManager.shared.playGameOverSound(won: true)
            }
        } else {
            message = "引き分け！ (\(darkCount) - \(lightCount))"
            SoundManager.shared.playGameOverSound(won: false)
        }
    }

    private func updateValidMoves() {
        validMoves = board.validMoves(for: currentTurn)
    }
}
