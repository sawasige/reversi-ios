import Foundation

final class AIPlayer: Sendable {
    let difficulty: AIDifficulty

    private static let positionWeights: [[Int]] = [
        [100, -20,  10,   5,   5,  10, -20, 100],
        [-20, -50,  -2,  -2,  -2,  -2, -50, -20],
        [ 10,  -2,   1,   1,   1,   1,  -2,  10],
        [  5,  -2,   1,   0,   0,   1,  -2,   5],
        [  5,  -2,   1,   0,   0,   1,  -2,   5],
        [ 10,  -2,   1,   1,   1,   1,  -2,  10],
        [-20, -50,  -2,  -2,  -2,  -2, -50, -20],
        [100, -20,  10,   5,   5,  10, -20, 100],
    ]

    init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
    }

    func bestMove(board: Board, for disk: Disk) -> Position? {
        let moves = board.validMoves(for: disk)
        guard !moves.isEmpty else { return nil }

        switch difficulty {
        case .easy:
            return moves.randomElement()
        case .medium, .hard:
            return minimaxBestMove(board: board, disk: disk, depth: difficulty.searchDepth)
        }
    }

    // MARK: - Minimax + Alpha-Beta Pruning

    private func minimaxBestMove(board: Board, disk: Disk, depth: Int) -> Position? {
        let moves = board.validMoves(for: disk)
        guard !moves.isEmpty else { return nil }

        var bestScore = Int.min
        var bestMove = moves[0]

        for move in moves {
            var newBoard = board
            newBoard.place(disk: disk, at: move)
            let score = minimax(
                board: newBoard, disk: disk, depth: depth - 1,
                alpha: Int.min, beta: Int.max, isMaximizing: false
            )
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return bestMove
    }

    private func minimax(
        board: Board, disk: Disk, depth: Int,
        alpha: Int, beta: Int, isMaximizing: Bool
    ) -> Int {
        if depth == 0 || board.isGameOver {
            return evaluate(board: board, for: disk)
        }

        let currentDisk = isMaximizing ? disk : disk.flipped
        let moves = board.validMoves(for: currentDisk)

        if moves.isEmpty {
            // Pass
            if board.validMoves(for: currentDisk.flipped).isEmpty {
                return evaluate(board: board, for: disk)
            }
            return minimax(
                board: board, disk: disk, depth: depth - 1,
                alpha: alpha, beta: beta, isMaximizing: !isMaximizing
            )
        }

        var alpha = alpha
        var beta = beta

        if isMaximizing {
            var maxScore = Int.min
            for move in moves {
                var newBoard = board
                newBoard.place(disk: currentDisk, at: move)
                let score = minimax(
                    board: newBoard, disk: disk, depth: depth - 1,
                    alpha: alpha, beta: beta, isMaximizing: false
                )
                maxScore = max(maxScore, score)
                alpha = max(alpha, score)
                if beta <= alpha { break }
            }
            return maxScore
        } else {
            var minScore = Int.max
            for move in moves {
                var newBoard = board
                newBoard.place(disk: currentDisk, at: move)
                let score = minimax(
                    board: newBoard, disk: disk, depth: depth - 1,
                    alpha: alpha, beta: beta, isMaximizing: true
                )
                minScore = min(minScore, score)
                beta = min(beta, score)
                if beta <= alpha { break }
            }
            return minScore
        }
    }

    // MARK: - Evaluation

    private func evaluate(board: Board, for disk: Disk) -> Int {
        let myCount = board.count(of: disk)
        let opponentCount = board.count(of: disk.flipped)

        if board.isGameOver {
            if myCount > opponentCount { return 10000 + (myCount - opponentCount) }
            if myCount < opponentCount { return -10000 - (opponentCount - myCount) }
            return 0
        }

        var score = 0

        // Position weights
        for row in 0..<Board.size {
            for col in 0..<Board.size {
                if let d = board.grid[row][col] {
                    let weight = Self.positionWeights[row][col]
                    score += (d == disk) ? weight : -weight
                }
            }
        }

        // Mobility
        let myMoves = board.validMoves(for: disk).count
        let opponentMoves = board.validMoves(for: disk.flipped).count
        score += (myMoves - opponentMoves) * 5

        // Piece count (weighted more in endgame)
        let totalPieces = myCount + opponentCount
        if totalPieces > 50 {
            score += (myCount - opponentCount) * 3
        }

        return score
    }
}
