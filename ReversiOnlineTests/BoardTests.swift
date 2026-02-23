import XCTest
@testable import ReversiOnline

final class BoardTests: XCTestCase {

    func testInitialBoard() {
        let board = Board()

        XCTAssertEqual(board[Position(row: 3, col: 3)], .light)
        XCTAssertEqual(board[Position(row: 3, col: 4)], .dark)
        XCTAssertEqual(board[Position(row: 4, col: 3)], .dark)
        XCTAssertEqual(board[Position(row: 4, col: 4)], .light)

        XCTAssertEqual(board.count(of: .dark), 2)
        XCTAssertEqual(board.count(of: .light), 2)
    }

    func testInitialValidMoves() {
        let board = Board()
        let moves = board.validMoves(for: .dark)

        XCTAssertEqual(moves.count, 4)
        XCTAssertTrue(moves.contains(Position(row: 2, col: 3)))
        XCTAssertTrue(moves.contains(Position(row: 3, col: 2)))
        XCTAssertTrue(moves.contains(Position(row: 4, col: 5)))
        XCTAssertTrue(moves.contains(Position(row: 5, col: 4)))
    }

    func testPlaceDisk() {
        var board = Board()
        let flipped = board.place(disk: .dark, at: Position(row: 2, col: 3))

        XCTAssertEqual(flipped.count, 1)
        XCTAssertTrue(flipped.contains(Position(row: 3, col: 3)))

        XCTAssertEqual(board[Position(row: 2, col: 3)], .dark)
        XCTAssertEqual(board[Position(row: 3, col: 3)], .dark)
        XCTAssertEqual(board.count(of: .dark), 4)
        XCTAssertEqual(board.count(of: .light), 1)
    }

    func testCannotPlaceOnOccupied() {
        let board = Board()
        XCTAssertFalse(board.canPlace(disk: .dark, at: Position(row: 3, col: 3)))
    }

    func testCannotPlaceWithNoFlips() {
        let board = Board()
        XCTAssertFalse(board.canPlace(disk: .dark, at: Position(row: 0, col: 0)))
    }

    func testGameNotOverAtStart() {
        let board = Board()
        XCTAssertFalse(board.isGameOver)
    }

    func testCornerDetection() {
        XCTAssertTrue(Board.isCorner(Position(row: 0, col: 0)))
        XCTAssertTrue(Board.isCorner(Position(row: 0, col: 7)))
        XCTAssertTrue(Board.isCorner(Position(row: 7, col: 0)))
        XCTAssertTrue(Board.isCorner(Position(row: 7, col: 7)))
        XCTAssertFalse(Board.isCorner(Position(row: 3, col: 3)))
    }

    func testMultipleFlips() {
        var board = Board()
        board.place(disk: .dark, at: Position(row: 2, col: 3))
        board.place(disk: .light, at: Position(row: 2, col: 2))
        board.place(disk: .dark, at: Position(row: 2, col: 1))

        XCTAssertEqual(board[Position(row: 2, col: 2)], .dark)
    }

    func testPositionValidity() {
        XCTAssertTrue(Position(row: 0, col: 0).isValid)
        XCTAssertTrue(Position(row: 7, col: 7).isValid)
        XCTAssertFalse(Position(row: -1, col: 0).isValid)
        XCTAssertFalse(Position(row: 0, col: 8).isValid)
        XCTAssertFalse(Position(row: 8, col: 8).isValid)
    }

    func testPassDetection() {
        let board = Board()
        // At start, both players have moves
        XCTAssertFalse(board.validMoves(for: .dark).isEmpty)
        XCTAssertFalse(board.validMoves(for: .light).isEmpty)
    }

    func testDiskFlipped() {
        XCTAssertEqual(Disk.dark.flipped, .light)
        XCTAssertEqual(Disk.light.flipped, .dark)
    }
}
