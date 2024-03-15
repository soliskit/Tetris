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
                // Draw the static blocks already placed on the game board
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
                
                // Draw the current falling piece
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
            .background(.white.opacity(0.8))
            .border(.black, width: 3)
        }
    }
}
