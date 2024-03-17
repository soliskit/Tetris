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
                Rectangle()
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: boardWidth, height: boardHeight)
                    .border(Color.black, width: 3)
                
                drawGridLines(boardWidth: boardWidth, boardHeight: boardHeight, blockSize: blockSize)
                
                // Draw blocks from the gameState's blocks collection
                ForEach(gameState.blocks) { block in
                    Rectangle()
                        .foregroundColor(block.color)
                        .frame(width: blockSize, height: blockSize)
                        .position(x: blockSize * CGFloat(block.x) + blockSize / 2,
                                  y: blockSize * CGFloat(block.y) + blockSize / 2)
                }
            }
            .frame(width: boardWidth, height: boardHeight)
        }
    }
    
    private func drawGridLines(boardWidth: CGFloat, boardHeight: CGFloat, blockSize: CGFloat) -> some View {
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
    }
}
