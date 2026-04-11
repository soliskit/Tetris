//
//  GameBoardView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct GameBoardView: View {
    private let rows: Int = 20
    private let columns: Int = 10
    var gameManager: GameManager

    var body: some View {
        GeometryReader { geometry in
            let blockSize = calculateBlockSize(from: geometry.size)
            let boardDimensions = calculateBoardDimensions(blockSize: blockSize)
            ZStack {
                GridLinesView(columns: columns, rows: rows, blockSize: blockSize, boardWidth: boardDimensions.width, boardHeight: boardDimensions.height)

                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { column in
                        if let cell = gameManager.gameBoard[safeRow: row, safeColumn: column], cell?.isFilled == true {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(cell?.color?.value ?? .clear)
                                .frame(width: blockSize - 1, height: blockSize - 1)
                                .position(x: blockSize * CGFloat(column) + blockSize / 2, y: blockSize * CGFloat(row) + blockSize / 2)
                        }
                    }
                }
                let tetromino = gameManager.currentTetromino
                ForEach(0..<tetromino.shape.count, id: \.self) { row in
                    ForEach(0..<tetromino.shape[row].count, id: \.self) { column in
                        if tetromino.shape[row][column] {
                            let tetrominoColumn = CGFloat(tetromino.position.column + column)
                            let tetrominoRow = CGFloat(tetromino.position.row + row)

                            if tetrominoColumn >= 0, tetrominoColumn < CGFloat(columns), tetrominoRow >= 0, tetrominoRow < CGFloat(rows) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(tetromino.color.value)
                                    .frame(width: blockSize - 1, height: blockSize - 1)
                                    .position(x: blockSize * tetrominoColumn + blockSize / 2,
                                              y: blockSize * tetrominoRow + blockSize / 2)
                            }
                        }
                    }
                }
                .frame(width: boardDimensions.width, height: boardDimensions.height)
            }
        }
    }

    private func calculateBlockSize(from size: CGSize) -> CGFloat {
        min(size.width / CGFloat(columns), size.height / CGFloat(rows))
    }

    private func calculateBoardDimensions(blockSize: CGFloat) -> CGSize {
        CGSize(width: blockSize * CGFloat(columns), height: blockSize * CGFloat(rows))
    }
}

struct GridLinesView: View {
    let columns: Int
    let rows: Int
    let blockSize: CGFloat
    let boardWidth: CGFloat
    let boardHeight: CGFloat

    var body: some View {
        Path { path in
            for column in 1..<columns {
                let x = blockSize * CGFloat(column)
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: boardHeight))
            }
            for row in 1..<rows {
                let y = blockSize * CGFloat(row)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: boardWidth, y: y))
            }
        }
        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
    }
}
