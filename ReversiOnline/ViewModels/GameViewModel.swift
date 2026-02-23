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
        updateValidMoves()
    }

    // MARK: - Private

    private func executePlacement(at position: Position) {
        isAnimating = true
        lastMove = position
        let flipped = board.place(disk: currentTurn, at: position)

        let animDuration = 0.3 + Double(flipped.count) * 0.05

        Task {
            try? await Task.sleep(for: .seconds(animDuration))
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

        if let winner = GameResult(darkCount: darkCount, lightCount: lightCount).winner {
            message = "\(winner.name)の勝ち！ (\(darkCount) - \(lightCount))"
        } else {
            message = "引き分け！ (\(darkCount) - \(lightCount))"
        }
    }

    private func updateValidMoves() {
        validMoves = board.validMoves(for: currentTurn)
    }
}
