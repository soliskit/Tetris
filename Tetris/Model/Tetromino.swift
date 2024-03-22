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
        let nextRotationState = (rotationState + 1) % rotations.count
        let nextShape = rotations[nextRotationState]
        let testPositions = [position] + wallKickData[rotationState].map { Position(row: position.row + $0.row, column: position.column + $0.column) }
        if let validPosition = testPositions.first(where: { Tetromino(shape: nextShape, color: color, position: $0, rotations: rotations, wallKickData: wallKickData).fitsWithin(gameBoard: gameBoard) }) {
            shape = nextShape
            rotationState = nextRotationState
            position = validPosition
        }
    }
}
