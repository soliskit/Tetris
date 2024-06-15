//
//  TetrominoPreview.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrominoPreview: View {
    private let columns: Int = 6
    private let rows: Int = 6
    var tetromino: Tetromino?
    
    var body: some View {
        GeometryReader { geometry in
            let blockSize = min(geometry.size.width / CGFloat(columns), geometry.size.height / CGFloat(rows))
            let boardWidth = blockSize * CGFloat(columns)
            let boardHeight = blockSize * CGFloat(rows)
            
            ZStack {
                Rectangle()
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: boardWidth, height: boardHeight)
                    .border(.black, width: 2)
                
                if let shape = tetromino?.shape, let color = tetromino?.color.value {
                    let xOffset = (boardWidth - CGFloat(shape[0].count) * blockSize) / 2
                    let yOffset = (boardHeight - CGFloat(shape.count) * blockSize) / 2
                    
                    ForEach(0..<shape.count, id: \.self) { row in
                        ForEach(0..<shape[row].count, id: \.self) { column in
                            if shape[row][column] {
                                Rectangle()
                                    .foregroundColor(color)
                                    .frame(width: blockSize, height: blockSize)
                                    .offset(x: blockSize * CGFloat(column) + xOffset - boardWidth / 2 + blockSize / 2,
                                            y: blockSize * CGFloat(row) + yOffset - boardHeight / 2 + blockSize / 2)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 100, height: 100)
    }
}

#Preview("Tetronimo Preview") {
    TetrominoPreview(tetromino: TetrominoFactory.generate())
}
