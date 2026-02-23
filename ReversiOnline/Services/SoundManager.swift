import AVFoundation

@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isSoundEnabled = true

    private var audioPlayers: [String: AVAudioPlayer] = [:]

    private init() {}

    func playPlaceSound() {
        play("place")
    }

    func playFlipSound() {
        play("flip")
    }

    func playGameOverSound(won: Bool) {
        play(won ? "victory" : "defeat")
    }

    private func play(_ name: String) {
        guard isSoundEnabled else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayers[name] = player
            player.play()
        } catch {
            print("Sound play error: \(error)")
        }
    }
}
