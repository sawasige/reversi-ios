import SwiftUI

struct CellView: View {
    let disk: Disk?
    let isValidMove: Bool
    let isLastMove: Bool
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
                .border(Color.black.opacity(0.3), width: 0.5)

            if isLastMove {
                Rectangle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: cellSize, height: cellSize)
            }

            if isValidMove && disk == nil {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: cellSize * 0.3, height: cellSize * 0.3)
            }

            if let disk = disk {
                PieceView(disk: disk, size: cellSize * 0.8)
                    .id(disk)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: disk)
    }
}
