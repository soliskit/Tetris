//
//  Tetromino.swift
//  Tetris
//
//  Created by David Solis on 3/20/24.
//

import SwiftUI

/// Represents a Tetromino, the game pieces used in Tetris.
///
/// A Tetromino has a specific shape, color, position on the game board, and can be rotated.
struct Tetromino: Identifiable {
    /// Unique identifier for conforming to `Identifiable`.
    let id = UUID()
    /// The 2D array representation of the Tetromino's shape. Each `true` value indicates a block is present.
    var shape: [[Bool]]
    /// The color of the Tetromino, used for UI display.
    var color: Color
    /// The current position of the Tetromino on the game board.
    var position: Position
    /// The current rotation state of the Tetromino. Used to handle the Tetromino's orientation.
    var rotationState: Int = 0
    /// A collection of points defining the Tetromino's shape at each rotation state.
    var rotationPoints: [[[Int]]]
    /// Wall kick data specifying how to adjust the Tetromino's position when rotating near a wall.
    var wallKickData: [[CGPoint]]
    
    mutating func rotate(gameBoard: [[GameCell]]) {
        let nextState = (rotationState + 1) % 4
        let potentialShape = rotatedShape()
        let kicks = wallKickData[safe: rotationState * 4 + nextState] ?? []
        
        for kick in kicks {
            let testPosition = Position(row: position.row + kick.y, column: position.column + kick.x)
            if canPlaceTetromino(at: testPosition, withShape: potentialShape, on: gameBoard) {
                position = testPosition
                shape = potentialShape
                rotationState = nextState
                return
            }
        }
    }

    private func rotatedShape() -> [[Bool]] {
        let size = shape.count
        var newShape = Array(repeating: Array(repeating: false, count: size), count: size)
        
        for row in 0..<size {
            for col in 0..<size {
                newShape[col][size - row - 1] = shape[row][col]
            }
        }
        
        return newShape
    }
    
    private func canPlaceTetromino(at position: Position, withShape shape: [[Bool]], on gameBoard: [[GameCell]]) -> Bool {
        for (rowIndex, row) in shape.enumerated() {
            for (colIndex, block) in row.enumerated() where block {
                let boardRow = position.row + CGFloat(rowIndex)
                let boardColumn = position.column + CGFloat(colIndex)
                
                let boardRowIndex = Int(boardRow)
                let boardColumnIndex = Int(boardColumn)
                
                // Use safe subscript for out-of-bounds check
                guard let row = gameBoard[safe: boardRowIndex], let cell = row[safe: boardColumnIndex] else {
                    return false // Out of bounds
                }
                
                if cell.isFilled {
                    return false // Collision detected
                }
            }
        }
        return true // No collision and within bounds, can place Tetromino
    }
}
