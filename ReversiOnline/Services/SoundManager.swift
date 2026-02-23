import AudioToolbox
import UIKit

@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isSoundEnabled = true

    private init() {}

    func playPlaceSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Tock
    }

    func playFlipSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1103) // Tink
    }

    func playPassSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1057)
    }

    func playGameOverSound(won: Bool) {
        guard isSoundEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(won ? .success : .error)
    }
}
