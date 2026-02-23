import SwiftUI

struct PieceView: View {
    let disk: Disk
    let size: CGFloat
    var flipDelay: Double?

    @State private var displayedDisk: Disk
    @State private var yRotation: Double = 0
    @State private var appeared = false

    init(disk: Disk, size: CGFloat, flipDelay: Double? = nil) {
        self.disk = disk
        self.size = size
        self.flipDelay = flipDelay
        _displayedDisk = State(initialValue: disk)
    }

    var body: some View {
        Circle()
            .fill(diskGradient(for: displayedDisk))
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 2)
            .rotation3DEffect(
                .degrees(yRotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
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
            .onChange(of: disk) { oldValue, newValue in
                guard oldValue != newValue else { return }
                performFlip(to: newValue, delay: flipDelay ?? 0)
            }
    }

    private func performFlip(to newDisk: Disk, delay: Double) {
        // First half: rotate to 90° (edge-on, still showing old color)
        withAnimation(.easeIn(duration: 0.2).delay(delay)) {
            yRotation = 90
        }
        // At midpoint: switch displayed color and rotate back
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(delay + 0.2))
            displayedDisk = newDisk
            withAnimation(.easeOut(duration: 0.2)) {
                yRotation = 0
            }
        }
    }

    private func diskGradient(for disk: Disk) -> RadialGradient {
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
