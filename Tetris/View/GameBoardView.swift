//
//  GameBoardView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct GameBoardView: View {
    var gameState: GameState
    
    var body: some View {
        GeometryReader { geometry in
            let blockSize = min(geometry.size.width / CGFloat(gameState.columns), geometry.size.height / CGFloat(gameState.rows))
            let boardWidth = blockSize * CGFloat(gameState.columns)
            let boardHeight = blockSize * CGFloat(gameState.rows)
            
            ZStack {
                // Background for the grid to make grid lines visible on all backgrounds
                Rectangle()
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: boardWidth, height: boardHeight)
                    .border(Color.black, width: 3)
                
                // Grid lines
                Path { path in
                    // Vertical lines
                    for column in 1..<gameState.columns {
                        let x = blockSize * CGFloat(column)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: boardHeight))
                    }
                    // Horizontal lines
                    for row in 1..<gameState.rows {
                        let y = blockSize * CGFloat(row)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: boardWidth, y: y))
                    }
                }
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                
                // Static blocks already placed on the game board
                ForEach(0..<gameState.rows, id: \.self) { row in
                    ForEach(0..<gameState.columns, id: \.self) { column in
                        if let color = gameState.board[row][column] {
                            Rectangle()
                                .foregroundColor(color)
                                .frame(width: blockSize, height: blockSize)
                                .position(x: blockSize * CGFloat(column) + blockSize / 2,
                                          y: blockSize * CGFloat(row) + blockSize / 2)
                        }
                    }
                }
                
                // Current falling piece
                if let piece = gameState.currentPiece {
                    ForEach(0..<piece.shape.count, id: \.self) { rowIndex in
                        ForEach(0..<piece.shape[rowIndex].count, id: \.self) { columnIndex in
                            if piece.shape[rowIndex][columnIndex] {
                                Rectangle()
                                    .foregroundColor(piece.color)
                                    .frame(width: blockSize, height: blockSize)
                                    .position(x: blockSize * (CGFloat(columnIndex) + piece.position.x) + blockSize / 2,
                                              y: blockSize * (CGFloat(rowIndex) + piece.position.y) + blockSize / 2)
                            }
                        }
                    }
                }
            }
            .frame(width: boardWidth, height: boardHeight)
        }
    }
}
