//
//  Tetromino.swift
//  Tetris
//
//  Created by David Solis on 3/20/24.
//

import SwiftUI

/// Represents a Tetromino shape in a Tetris game
struct Tetromino: Identifiable {
    /// Unique identifier for each Tetromino instance.
    let id = UUID()
    /// 2D array representing the shape of the Tetromino, where `true` indicates a filled block.
    var shape: [[Bool]]
    /// Color of the Tetromino.
    var color: Color
    /// Current row position of the Tetromino in the game board.
    var row: CGFloat
    /// Current column position of the Tetromino in the game board.
    var column: CGFloat
    /// Current rotation state of the Tetromino, represented as an integer.
    var rotationState: Int = 0
    
    /// Rotation points used to calculate the new shape of the Tetromino after rotation.
    var rotationPoints: [[[Int]]]
    /// Wall kick data to adjust the position of the Tetromino when it rotates next to a wall or another Tetromino.
    var wallKickData: [[CGPoint]]
    
    /// Rotates the Tetromino clockwise, checking for collisions and applying wall kicks if necessary.
    mutating func rotate() {
        let previousState = rotationState
        let nextState = (rotationState + 1) % 4
        let newShape = rotatedShape()
        rotationState = nextState
        if checksCollision(for: newShape, atRow: row, andColumn: column) {
            if !applyWallKick(from: previousState, to: nextState) {
                rotationState = previousState
            } else {
                shape = newShape
            }
        } else {
            shape = newShape
        }
    }
    
    /// Calculates the new shape of the Tetromino after a rotation operation.
    /// - Returns: A 2D array representing the new shape of the Tetromino.
    private func rotatedShape() -> [[Bool]] {
        let size = shape.count
        return (0..<size).map { row in
            (0..<size).map { col in
                shape[col][size - row - 1]
            }
        }
    }
    
    mutating func applyWallKick(from previousState: Int, to nextState: Int) -> Bool {
        let kickIndex = previousState * 4 + nextState
        guard wallKickData.indices.contains(kickIndex) else { return false }
        return wallKickData[kickIndex].contains { kickPosition in
            let testRow = row + kickPosition.y
            let testColumn = column + kickPosition.x
            if !checksCollision(for: shape, atRow: testRow, andColumn: testColumn) {
                row += kickPosition.y
                column += kickPosition.x
                return true
            }
            return false
        }
    }
    
    /// Checks if the Tetromino collides with the game board boundaries or other Tetrominos after a move or rotation.
    /// - Parameters:
    ///   - shape: The 2D array representing the shape of the Tetromino to check for collisions.
    ///   - row: The row position of the Tetromino on the game board.
    ///   - column: The column position of the Tetromino on the game board.
    /// - Returns: A Boolean value indicating whether a collision occurs.
    private func checksCollision(for shape: [[Bool]], atRow row: CGFloat, andColumn column: CGFloat) -> Bool {
        let boardRows = 20
        let boardColumns = 10
        return shape.enumerated().contains { (shapeRow, rowContents) in
            rowContents.enumerated().contains { (shapeColumn, isOccupied) in
                isOccupied && {
                    let boardRow = Int(row) + shapeRow
                    let boardColumn = Int(column) + shapeColumn
                    return boardRow < 0 || boardRow >= boardRows || boardColumn < 0 || boardColumn >= boardColumns
                }()
            }
        }
    }
}
