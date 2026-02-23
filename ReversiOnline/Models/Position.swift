import Foundation

struct Position: Equatable, Hashable, Codable {
    let row: Int
    let col: Int

    var isValid: Bool {
        (0..<8).contains(row) && (0..<8).contains(col)
    }

    func moved(by direction: Direction) -> Position {
        Position(row: row + direction.dr, col: col + direction.dc)
    }
}

struct Direction {
    let dr: Int
    let dc: Int

    static let all: [Direction] = [
        Direction(dr: -1, dc: -1), Direction(dr: -1, dc: 0), Direction(dr: -1, dc: 1),
        Direction(dr:  0, dc: -1),                            Direction(dr:  0, dc: 1),
        Direction(dr:  1, dc: -1), Direction(dr:  1, dc: 0), Direction(dr:  1, dc: 1),
    ]
}
