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
    
    /// Rotates the Tetromino, updating its shape and position if necessary.
    ///
    /// - Parameters:
    ///   - gameBoard: The current state of the game board, to check for collisions and bounds.
    mutating func rotate(gameBoard: [[GameCell]]) {
        let previousState = rotationState
        rotationState = (rotationState + 1) % 4
        let newShape = rotatedShape()
        
        if isWithinBoundsAndNotColliding(for: newShape, atRow: position.row, andColumn: position.column, gameBoard: gameBoard) {
            if !applyWallKick(from: previousState, to: rotationState, gameBoard: gameBoard) {
                rotationState = previousState
            } else {
                shape = newShape
            }
        } else {
            shape = newShape
        }
    }
    
    /// Attempts to apply a wall kick to the Tetromino, shifting its position to avoid collision after a rotation.
    ///
    /// - Parameters:
    ///   - previousState: The rotation state before the attempted rotation.
    ///   - nextState: The rotation state after the attempted rotation.
    ///   - gameBoard: The current state of the game board, to check for collisions and bounds.
    /// - Returns: `true` if a wall kick was successfully applied, otherwise `false`.
    private mutating func applyWallKick(from previousState: Int, to nextState: Int, gameBoard: [[GameCell]]) -> Bool {
        let kickIndex = previousState * 4 + nextState
        guard wallKickData.indices.contains(kickIndex) else { return false }
        return wallKickData[kickIndex].contains { kickPosition in
            let testRow = position.row + kickPosition.y
            let testColumn = position.column + kickPosition.x
            if !isWithinBoundsAndNotColliding(for: shape, atRow: testRow, andColumn: testColumn, gameBoard: gameBoard) {
                position.row += kickPosition.y
                position.column += kickPosition.x
                return true
            }
            return false
        }
    }
    
    /// Calculates the Tetromino's shape after a rotation.
    ///
    /// - Returns: A 2D array representing the Tetromino's new shape.
    private func rotatedShape() -> [[Bool]] {
        let size = shape.count
        return (0..<size).map { row in
            (0..<size).map { col in
                shape[col][size - row - 1]
            }
        }
    }
    
    /// Determines if a new shape for the Tetromino, at a given row and column, is within bounds and not colliding with other Tetrominos.
    ///
    /// - Parameters:
    ///   - newShape: The new shape to check.
    ///   - atRow: The row position to place the new shape.
    ///   - andColumn: The column position to place the new shape.
    ///   - gameBoard: The current state of the game board, to check for collisions and bounds.
    /// - Returns: `true` if the new shape is within bounds and not colliding, otherwise `false`.
    private func isWithinBoundsAndNotColliding(for newShape: [[Bool]], atRow: CGFloat, andColumn: CGFloat, gameBoard: [[GameCell]]) -> Bool {
        !newShape.enumerated().contains { rowIndex, row in
            row.enumerated().contains { columnIndex, isFilled in
                if isFilled {
                    let boardRow = Int(atRow) + rowIndex
                    let boardColumn = Int(andColumn) + columnIndex
                    
                    return boardRow < 0 || boardRow >= 20 || boardColumn < 0 || boardColumn >= 10 ||
                    (gameBoard.indices.contains(boardRow) && gameBoard[boardRow].indices.contains(boardColumn) && gameBoard[boardRow][boardColumn].isFilled)
                }
                return false
            }
        }
    }
}
