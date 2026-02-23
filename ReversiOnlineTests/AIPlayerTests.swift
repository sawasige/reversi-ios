import XCTest
@testable import ReversiOnline

final class AIPlayerTests: XCTestCase {

    func testEasyAIReturnsValidMove() {
        let ai = AIPlayer(difficulty: .easy)
        let board = Board()
        let move = ai.bestMove(board: board, for: .dark)

        XCTAssertNotNil(move)
        if let move = move {
            XCTAssertTrue(board.canPlace(disk: .dark, at: move))
        }
    }

    func testMediumAIReturnsValidMove() {
        let ai = AIPlayer(difficulty: .medium)
        let board = Board()
        let move = ai.bestMove(board: board, for: .dark)

        XCTAssertNotNil(move)
        if let move = move {
            XCTAssertTrue(board.canPlace(disk: .dark, at: move))
        }
    }

    func testHardAIReturnsValidMove() {
        let ai = AIPlayer(difficulty: .hard)
        let board = Board()
        let move = ai.bestMove(board: board, for: .dark)

        XCTAssertNotNil(move)
        if let move = move {
            XCTAssertTrue(board.canPlace(disk: .dark, at: move))
        }
    }

    func testAIReturnsNilWhenNoMoves() {
        let ai = AIPlayer(difficulty: .easy)
        var grid: [[Disk?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        grid[0][0] = .light
        let board = Board(grid: grid)
        let move = ai.bestMove(board: board, for: .dark)

        XCTAssertNil(move)
    }
}
