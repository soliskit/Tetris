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
    var rotationState: Int
    
    init(shape: [[Bool]], color: Color, position: Position, rotations: [[[Bool]]], rotationState: Int = 0) {
        self.shape = shape
        self.color = color
        self.position = position
        self.rotations = rotations
        self.rotationState = rotationState
    }
    
    mutating func rotate(gameBoard: [[GameCell]]) {
        let nextRotationState = (rotationState + 1) % rotations.count
        let nextShape = rotations[nextRotationState]
        let testPositions = [
            Position(row: position.row, column: position.column),
            Position(row: position.row, column: position.column - 1),
            Position(row: position.row, column: position.column + 1),
            Position(row: position.row - 1, column: position.column),
            Position(row: position.row + 1, column: position.column)
        ]
        
        if let validPosition = testPositions.first(where: { checkIfValidPosition(for: nextShape, at: $0, on: gameBoard) }) {
            shape = nextShape
            rotationState = nextRotationState
            position = validPosition
        }
    }
    
    private func checkIfValidPosition(for shape: [[Bool]], at position: Position, on gameBoard: [[GameCell]]) -> Bool {
        for (y, row) in shape.enumerated() {
            for (x, block) in row.enumerated() where block {
                let gameBoardX = Int(position.column) + x
                let gameBoardY = Int(position.row) + y
                
                guard gameBoard.indices.contains(gameBoardY),
                      gameBoard[gameBoardY].indices.contains(gameBoardX) else {
                    return false
                }
                
                if gameBoard[gameBoardY][gameBoardX].isFilled {
                    return false
                }
            }
        }
        return true
    }
}
