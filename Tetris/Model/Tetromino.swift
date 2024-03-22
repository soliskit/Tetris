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
    let id = UUID()
    var shape: [[Bool]]
    var color: Color
    var position: Position
    var rotations: [[[Bool]]]
    var rotationState: Int = 0
    var wallKickData: [[Position]]
    
    func fitsWithin(gameBoard: [[GameCell?]]) -> Bool {
        return !shape.enumerated().contains { rowIndex, row in
            row.enumerated().contains { columnIndex, block in
                guard block else { return false }
                let boardX = Int(position.column) + columnIndex
                let boardY = Int(position.row) + rowIndex
                if let gameBoardRow = gameBoard[safe: boardY], let gameBoardCell = gameBoardRow[safe: boardX] {
                    return gameBoardCell?.isFilled == true
                }
                return true
            }
        }
    }
    
    mutating func rotate(gameBoard: [[GameCell?]]) {
        let clockwiseRotationState = (rotationState + 1) % rotations.count
        let clockwiseShape = rotations[clockwiseRotationState]
        let clockwiseTestPositions = wallKickData[clockwiseRotationState].map {
            Position(row: position.row + $0.row, column: position.column + $0.column)
        }
        if let validClockwisePosition = clockwiseTestPositions.first(where: {
            Tetromino(shape: clockwiseShape, color: color, position: $0, rotations: rotations, wallKickData: wallKickData)
                .fitsWithin(gameBoard: gameBoard)
        }) {
            shape = clockwiseShape
            rotationState = clockwiseRotationState
            position = validClockwisePosition
            return
        }
        
        let counterClockwiseRotationState = (rotationState - 1 + rotations.count) % rotations.count
        let counterClockwiseShape = rotations[counterClockwiseRotationState]
        let counterClockwiseTestPositions = wallKickData[counterClockwiseRotationState].map {
            Position(row: position.row + $0.row, column: position.column + $0.column)
        }
        
        for testPosition in counterClockwiseTestPositions {
            if Tetromino(shape: counterClockwiseShape, color: color, position: testPosition, rotations: rotations, wallKickData: wallKickData)
                .fitsWithin(gameBoard: gameBoard) {
                shape = counterClockwiseShape
                rotationState = counterClockwiseRotationState
                position = testPosition
                break
            }
        }
    }
}
