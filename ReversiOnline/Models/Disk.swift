import Foundation

enum Disk: Int, CaseIterable, Codable {
    case dark = 0   // 黒（先手）
    case light = 1  // 白（後手）

    var flipped: Disk {
        self == .dark ? .light : .dark
    }

    var name: String {
        self == .dark ? "黒" : "白"
    }
}
