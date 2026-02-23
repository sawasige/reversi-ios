import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    init(mode: GameMode) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode))
    }

    var body: some View {
        VStack(spacing: 20) {
            ScoreView(
                darkCount: viewModel.darkCount,
                lightCount: viewModel.lightCount,
                currentTurn: viewModel.currentTurn,
                phase: viewModel.phase
            )

            BoardView(viewModel: viewModel)

            Text(viewModel.message)
                .font(.headline)
                .foregroundStyle(.secondary)
                .animation(.easeInOut, value: viewModel.message)

            if viewModel.phase == .gameOver {
                HStack(spacing: 16) {
                    Button("もう一度") {
                        viewModel.restart()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("メニューに戻る") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .padding()
        .navigationTitle(modeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.restart()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .disabled(viewModel.isAnimating)
            }
        }
        .animation(.easeInOut, value: viewModel.phase)
    }

    private var modeTitle: String {
        switch viewModel.gameMode {
        case .local:
            return "ローカル対戦"
        case .ai(let difficulty):
            return "CPU対戦 (\(difficulty.rawValue))"
        }
    }
}
