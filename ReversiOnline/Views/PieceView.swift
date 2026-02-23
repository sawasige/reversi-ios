import SwiftUI

struct PieceView: View {
    let disk: Disk
    let size: CGFloat

    @State private var appeared = false

    var body: some View {
        Circle()
            .fill(diskGradient)
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 2)
            .scaleEffect(appeared ? 1.0 : 0.1)
            .rotation3DEffect(
                .degrees(appeared ? 0 : 90),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .onAppear {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    appeared = true
                }
            }
    }

    private var diskGradient: some ShapeStyle {
        if disk == .dark {
            RadialGradient(
                colors: [Color(white: 0.3), Color.black],
                center: .init(x: 0.35, y: 0.35),
                startRadius: 0,
                endRadius: size * 0.6
            )
        } else {
            RadialGradient(
                colors: [Color.white, Color(white: 0.85)],
                center: .init(x: 0.35, y: 0.35),
                startRadius: 0,
                endRadius: size * 0.6
            )
        }
    }
}
