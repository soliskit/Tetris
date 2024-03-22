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
                BoardBackgroundView(boardWidth: boardDimensions.width, boardHeight: boardDimensions.height)
                GridLinesView(columns: columns, rows: rows, blockSize: blockSize, boardWidth: boardDimensions.width, boardHeight: boardDimensions.height)
                
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { column in
                        let cell = gameManager.gameBoard[row][column]
                        Rectangle()
                            .fill(cell?.isFilled ?? false ? cell?.color ?? .clear : .clear)
                            .frame(width: blockSize, height: blockSize)
                            .position(x: blockSize * CGFloat(column) + blockSize / 2, y: blockSize * CGFloat(row) + blockSize / 2)
                    }
                }
                
                ForEach(0..<gameManager.currentTetromino.shape.count, id: \.self) { row in
                    if let currentRow = gameManager.currentTetromino.shape[safe: row] {
                        ForEach(0..<currentRow.count, id: \.self) { column in
                            if let cell = currentRow[safe: column], cell {
                                let tetrominoColumn = CGFloat(column) + gameManager.currentTetromino.position.column
                                let tetrominoRow = CGFloat(row) + gameManager.currentTetromino.position.row
                                
                                if tetrominoColumn >= 0, tetrominoColumn < CGFloat(columns), tetrominoRow >= 0, tetrominoRow < CGFloat(rows) {
                                    Rectangle()
                                        .fill(gameManager.currentTetromino.color)
                                        .frame(width: blockSize, height: blockSize)
                                        .position(x: blockSize * tetrominoColumn + blockSize / 2,
                                                  y: blockSize * tetrominoRow + blockSize / 2)
                                }
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
