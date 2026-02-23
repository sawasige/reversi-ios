import SwiftUI

struct HomeView: View {
    @State private var selectedMode: GameMode?
    @State private var showDifficultyPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("リバーシ")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("REVERSI ONLINE")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 60)

                VStack(spacing: 16) {
                    MenuButton(title: "ローカル対戦", subtitle: "1台で2人対戦", icon: "person.2.fill") {
                        selectedMode = .local
                    }

                    MenuButton(title: "CPU対戦", subtitle: "コンピュータと対戦", icon: "cpu") {
                        showDifficultyPicker = true
                    }

                    MenuButton(title: "オンライン対戦", subtitle: "準備中...", icon: "wifi", disabled: true) {
                        // Phase 4
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
                Spacer()
            }
            .navigationDestination(item: $selectedMode) { mode in
                GameView(mode: mode)
            }
            .confirmationDialog("難易度を選択", isPresented: $showDifficultyPicker) {
                ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                    Button(difficulty.rawValue) {
                        selectedMode = .ai(difficulty)
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}
