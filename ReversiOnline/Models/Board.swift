import Foundation

struct Board: Equatable {
    static let size = 8

    private(set) var grid: [[Disk?]]

    init() {
        grid = Array(repeating: Array(repeating: nil, count: Board.size), count: Board.size)
        grid[3][3] = .light
        grid[3][4] = .dark
        grid[4][3] = .dark
        grid[4][4] = .light
    }

    init(grid: [[Disk?]]) {
        self.grid = grid
    }

    subscript(position: Position) -> Disk? {
        guard position.isValid else { return nil }
        return grid[position.row][position.col]
    }

    // MARK: - Move Validation

    func flippableDisks(for disk: Disk, at position: Position) -> [Position] {
        guard position.isValid, grid[position.row][position.col] == nil else { return [] }

        var result: [Position] = []

        for direction in Direction.all {
            var candidates: [Position] = []
            var current = position.moved(by: direction)

            while current.isValid {
                guard let occupant = grid[current.row][current.col] else { break }
                if occupant == disk.flipped {
                    candidates.append(current)
                } else {
                    result.append(contentsOf: candidates)
                    break
                }
                current = current.moved(by: direction)
            }
        }

        return result
    }

    func canPlace(disk: Disk, at position: Position) -> Bool {
        !flippableDisks(for: disk, at: position).isEmpty
    }

    func validMoves(for disk: Disk) -> [Position] {
        var moves: [Position] = []
        for row in 0..<Board.size {
            for col in 0..<Board.size {
                let pos = Position(row: row, col: col)
                if canPlace(disk: disk, at: pos) {
                    moves.append(pos)
                }
            }
        }
        return moves
    }

    // MARK: - Placement

    @discardableResult
    mutating func place(disk: Disk, at position: Position) -> [Position] {
        let flips = flippableDisks(for: disk, at: position)
        guard !flips.isEmpty else { return [] }
        grid[position.row][position.col] = disk
        for pos in flips {
            grid[pos.row][pos.col] = disk
        }
        return flips
    }

    // MARK: - Queries

    func count(of disk: Disk) -> Int {
        grid.flatMap { $0 }.filter { $0 == disk }.count
    }

    var isGameOver: Bool {
        validMoves(for: .dark).isEmpty && validMoves(for: .light).isEmpty
    }

    static func isCorner(_ position: Position) -> Bool {
        let corners: Set<Position> = [
            Position(row: 0, col: 0), Position(row: 0, col: 7),
            Position(row: 7, col: 0), Position(row: 7, col: 7),
        ]
        return corners.contains(position)
    }
}
