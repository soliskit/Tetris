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
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        GeometryReader { geometry in
            let blockSize = calculateBlockSize(from: geometry.size)
            let boardDimensions = calculateBoardDimensions(blockSize: blockSize)
            ZStack {
                BoardBackgroundView(boardWidth: boardDimensions.width, boardHeight: boardDimensions.height)
                GridLinesView(columns: columns, rows: rows, blockSize: blockSize, boardWidth: boardDimensions.width, boardHeight: boardDimensions.height)
                TetrominosView(tetrominos: gameManager.tetrominos, blockSize: blockSize)
            }
            .frame(width: boardDimensions.width, height: boardDimensions.height)
        }
    }
    
    private func calculateBlockSize(from size: CGSize) -> CGFloat {
        min(size.width / CGFloat(columns), size.height / CGFloat(rows))
    }
    
    private func calculateBoardDimensions(blockSize: CGFloat) -> CGSize {
        CGSize(width: blockSize * CGFloat(columns), height: blockSize * CGFloat(rows))
    }
}

struct BoardBackgroundView: View {
    let boardWidth: CGFloat
    let boardHeight: CGFloat
    
    var body: some View {
        Rectangle()
            .foregroundColor(.white.opacity(0.8))
            .frame(width: boardWidth, height: boardHeight)
            .border(Color.black, width: 3)
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
        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
    }
}

struct TetrominosView: View {
    let tetrominos: [Tetromino]
    let blockSize: CGFloat
    
    var body: some View {
        ForEach(tetrominos) { tetromino in
            TetrominoView(tetromino: tetromino, blockSize: blockSize)
        }
    }
}

struct TetrominoView: View {
    let tetromino: Tetromino
    let blockSize: CGFloat
    
    var body: some View {
        GeometryReader { _ in
            ForEach(0..<tetromino.shape.count, id: \.self) { rowIdx in
                ForEach(0..<tetromino.shape[rowIdx].count, id: \.self) { colIdx in
                    if tetromino.shape[rowIdx][colIdx] {
                        Rectangle()
                            .foregroundColor(tetromino.color)
                            .frame(width: blockSize, height: blockSize)
                            .offset(x: blockSize * CGFloat(colIdx) + (tetromino.column * blockSize),
                                    y: blockSize * CGFloat(rowIdx) + (tetromino.row * blockSize))
                    }
                }
            }
        }
    }
}
