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
            let blockSize = min(geometry.size.width / CGFloat(columns), geometry.size.height / CGFloat(rows))
            let boardWidth = blockSize * CGFloat(columns)
            let boardHeight = blockSize * CGFloat(rows)
            
            ZStack {
                Rectangle()
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: boardWidth, height: boardHeight)
                    .border(Color.black, width: 3)
                
                drawGridLines(boardWidth: boardWidth, boardHeight: boardHeight, blockSize: blockSize)
                
                ForEach(gameManager.getAllBlocks(), id: \.id) { block in
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

#Preview("Game Board") {
    GameBoardView(gameManager: GameManager())
}
