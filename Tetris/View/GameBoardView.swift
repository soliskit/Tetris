//
//  GameBoardView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        GeometryReader { geometry in
            let blockSize = calculateBlockSize(from: geometry.size)
            let boardDimensions = calculateBoardDimensions(blockSize: blockSize)
            ZStack {
                BoardBackgroundView(boardWidth: boardDimensions.width, boardHeight: boardDimensions.height)
                GridLinesView(columns: gameManager.columns, rows: gameManager.rows, blockSize: blockSize, boardWidth: boardDimensions.width, boardHeight: boardDimensions.height)
                
                ForEach(0..<gameManager.rows, id: \.self) { row in
                    ForEach(0..<gameManager.columns, id: \.self) { column in
                        Rectangle()
                            .fill(gameManager.gameBoard[row][column].isFilled ? gameManager.gameBoard[row][column].color ?? .clear : .clear)
                            .frame(width: blockSize, height: blockSize)
                            .position(x: blockSize * CGFloat(column) + blockSize / 2, y: blockSize * CGFloat(row) + blockSize / 2)
                    }
                }
                
                ForEach(0..<gameManager.currentPiece.shape.count, id: \.self) { row in
                    ForEach(0..<gameManager.currentPiece.shape[row].count, id: \.self) { column in
                        if gameManager.currentPiece.shape[row][column] {
                            Rectangle()
                                .fill(gameManager.currentPiece.color)
                                .frame(width: blockSize, height: blockSize)
                                .position(x: blockSize * CGFloat(column + Int(gameManager.currentPiece.position.column)) + blockSize / 2,
                                          y: blockSize * CGFloat(row + Int(gameManager.currentPiece.position.row)) + blockSize / 2)
                        }
                    }
                }
            }
            .frame(width: boardDimensions.width, height: boardDimensions.height)
        }
    }
    
    private func calculateBlockSize(from size: CGSize) -> CGFloat {
        min(size.width / CGFloat(gameManager.columns), size.height / CGFloat(gameManager.rows))
    }
    
    private func calculateBoardDimensions(blockSize: CGFloat) -> CGSize {
        CGSize(width: blockSize * CGFloat(gameManager.columns), height: blockSize * CGFloat(gameManager.rows))
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
