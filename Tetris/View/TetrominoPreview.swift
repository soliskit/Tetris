//
//  TetrominoPreview.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrominoPreview: View {
    private let columns: Int = 4
    private let rows: Int = 4
    var tetromino: [Block]?
    
    var body: some View {
        GeometryReader { geometry in
            let blockSize = min(geometry.size.width / CGFloat(columns), geometry.size.height / CGFloat(rows))
            let boardWidth = blockSize * CGFloat(columns)
            let boardHeight = blockSize * CGFloat(rows)
            
            ZStack {
                Rectangle()
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: boardWidth, height: boardHeight)
                    .border(Color.black, width: 2)
                
                ForEach(tetromino ?? []) { block in
                    let xOffset = (CGFloat(columns) / 2.0) - CGFloat(tetrominoWidth()) / 2.0
                    let yOffset = (CGFloat(rows) / 2.0) - CGFloat(tetrominoHeight()) / 2.0
                    
                    Rectangle()
                        .foregroundColor(block.color)
                        .frame(width: blockSize, height: blockSize)
                        .position(x: blockSize * CGFloat(block.x - minX() + 1) + (blockSize * xOffset) - blockSize / 2,
                                  y: blockSize * CGFloat(block.y - minY() + 1) + (blockSize * yOffset) - blockSize / 2)
                }
            }
        }
        .frame(width: 100, height: 100) // Adjust this to change the size of the preview area
    }
    
    private func minX() -> Int {
        tetromino?.map { $0.x }.min() ?? 0
    }
    
    private func minY() -> Int {
        tetromino?.map { $0.y }.min() ?? 0
    }
    
    private func tetrominoWidth() -> Int {
        guard let blocks = tetromino else { return 0 }
        let xs = blocks.map { $0.x }
        return (xs.max() ?? 0) - (xs.min() ?? 0) + 1
    }
    
    private func tetrominoHeight() -> Int {
        guard let blocks = tetromino else { return 0 }
        let ys = blocks.map { $0.y }
        return (ys.max() ?? 0) - (ys.min() ?? 0) + 1
    }
}

#Preview("Tetronimo Preview") {
    TetrominoPreview(tetromino: TetrominoFactory.generate())
}
