import SwiftUI

struct ScoreView: View {
    let darkCount: Int
    let lightCount: Int
    let currentTurn: Disk
    let phase: GamePhase

    var body: some View {
        HStack(spacing: 32) {
            PlayerScoreView(
                disk: .dark,
                count: darkCount,
                isActive: phase == .playing && currentTurn == .dark
            )

            Text("vs")
                .font(.title3)
                .foregroundStyle(.tertiary)

            PlayerScoreView(
                disk: .light,
                count: lightCount,
                isActive: phase == .playing && currentTurn == .light
            )
        }
    }
}

struct PlayerScoreView: View {
    let disk: Disk
    let count: Int
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(disk == .dark ? Color.black : Color.white)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle().stroke(Color.gray, lineWidth: 1)
                    )

                if isActive {
                    Circle()
                        .stroke(Color.green, lineWidth: 3)
                        .frame(width: 40, height: 40)
                }
            }
            .frame(width: 44, height: 44)

            Text("\(count)")
                .font(.title2.bold())
                .contentTransition(.numericText())

            Text(disk.name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .animation(.easeInOut, value: count)
        .animation(.easeInOut, value: isActive)
    }
}
