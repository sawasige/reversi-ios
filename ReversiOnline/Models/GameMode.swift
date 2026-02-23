import Foundation

enum GameMode: Hashable {
    case local
    case ai(AIDifficulty)
}

enum AIDifficulty: String, CaseIterable, Hashable {
    case easy = "初級"
    case medium = "中級"
    case hard = "上級"

    var searchDepth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 4
        case .hard: return 6
        }
    }
}
