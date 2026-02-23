import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel

    private let boardPadding: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cellSize = (size - boardPadding * 2) / CGFloat(Board.size)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.boardGreen)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

                VStack(spacing: 0) {
                    ForEach(0..<Board.size, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<Board.size, id: \.self) { col in
                                let position = Position(row: row, col: col)
                                CellView(
                                    disk: viewModel.board[position],
                                    isValidMove: viewModel.validMoves.contains(position),
                                    isLastMove: viewModel.lastMove == position,
                                    cellSize: cellSize
                                )
                                .onTapGesture {
                                    viewModel.placeDisk(at: position)
                                }
                            }
                        }
                    }
                }
                .padding(boardPadding)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension Color {
    static let boardGreen = Color(red: 0.0, green: 0.5, blue: 0.25)
}
