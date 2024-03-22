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
                guard gameBoard.indices.contains(boardY), gameBoard[boardY].indices.contains(boardX) else {
                    return true
                }
                return gameBoard[boardY][boardX]?.isFilled == true
            }
        }
    }
    
    mutating func rotate(gameBoard: [[GameCell?]]) {
        let nextRotationState = (rotationState + 1) % rotations.count
        let nextShape = rotations[nextRotationState]
        let testPositions = [position] + wallKickData[rotationState].map { Position(row: position.row + $0.row, column: position.column + $0.column) }
        if let validPosition = testPositions.first(where: { checkIfValidPosition(for: nextShape, at: $0, on: gameBoard) }) {
            shape = nextShape
            rotationState = nextRotationState
            position = validPosition
        }
    }
    
    private func checkIfValidPosition(for shape: [[Bool]], at position: Position, on gameBoard: [[GameCell?]]) -> Bool {
        return !shape.enumerated().contains { y, row in
            row.enumerated().contains { x, block in
                guard block else { return false }
                return !fitsWithin(gameBoard: gameBoard)
            }
        }
    }
}
