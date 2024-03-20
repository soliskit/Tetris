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
    
    /// Rotates the Tetromino clockwise or counterclockwise, checking for collisions and applying wall kicks if necessary.
    /// - Parameter isClockwise: A Boolean value indicating the direction of the rotation (true for clockwise).
    mutating func rotate(clockwise isClockwise: Bool) {
        let previousState = rotationState
        let directionAdjustment = isClockwise ? 1 : -1
        rotationState = (rotationState + directionAdjustment + 4) % 4
        let newShape = rotatedShape(clockwise: isClockwise)
        if checksCollision(for: newShape, atRow: row, andColumn: column) {
            rotationState = previousState
            return
        }
        shape = newShape
        if !applyWallKick(from: previousState) {
            rotationState = previousState
            shape = rotatedShape(clockwise: !(isClockwise))
        }
    }
    
    /// Calculates the new shape of the Tetromino after a rotation operation.
    /// - Parameter isClockwise: A Boolean value indicating the direction of the rotation.
    /// - Returns: A 2D array representing the new shape of the Tetromino.
    private func rotatedShape(clockwise isClockwise: Bool) -> [[Bool]] {
        let size = shape.count
        var newShape = Array(repeating: Array(repeating: false, count: size), count: size)
        newShape = (0..<size).map { row in
            (0..<size).map { col in
                isClockwise ? shape[col][size - row - 1] : shape[size - col - 1][row]
            }
        }
        return newShape
    }
    
    /// Checks if the Tetromino can rotate without colliding with the game board boundaries or other Tetrominos.
    /// - Parameter isClockwise: A Boolean value indicating the direction of the rotation.
    /// - Returns: A Boolean value indicating whether the rotation can be performed.
    private func canRotate(clockwise isClockwise: Bool) -> Bool {
        let directionAdjustment = isClockwise ? 1 : -1
        let potentialRotationState = (rotationState + directionAdjustment + 4) % 4
        let potentialShape = rotatedShape(clockwise: isClockwise)
        if checksCollision(for: potentialShape, atRow: row, andColumn: column) {
            return false
        }
        let result = wallKickData[rotationState].enumerated().contains { index, offset in
            let potentialRow = row + (isClockwise ? offset.y : -offset.y)
            let potentialColumn = column + (isClockwise ? offset.x : -offset.x)
            let correspondingWallKick = wallKickData[potentialRotationState][index]
            let testRow = potentialRow + (isClockwise ? correspondingWallKick.y : -correspondingWallKick.y)
            let testColumn = potentialColumn + (isClockwise ? correspondingWallKick.x : -correspondingWallKick.x)
            return !checksCollision(for: potentialShape, atRow: testRow, andColumn: testColumn)
        }
        return result
    }
    
    /// Applies a wall kick to adjust the position of the Tetromino if it collides after a rotation.
    /// - Parameter previousState: The rotation state of the Tetromino before the attempted rotation.
    /// - Returns: A Boolean value indicating whether a wall kick was successfully applied.
    private mutating func applyWallKick(from previousState: Int) -> Bool {
        guard let testPositions = wallKickData[safe: previousState * 4 + rotationState] else { return false }
        return testPositions.first(where: { testPosition in
            !checksCollision(for: shape, atRow: row + testPosition.y, andColumn: column + testPosition.x)
        }).map { testPosition in
            row += testPosition.y
            column += testPosition.x
            return true
        } != nil
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
