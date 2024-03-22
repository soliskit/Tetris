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
        self.shape = rotations[0]
        self.color = color
        self.position = position
        self.rotations = rotations
        self.rotationState = rotationState
    }
    
    mutating func rotate() {
        rotationState = (rotationState + 1) % rotations.count
        shape = rotations[rotationState]
    }
}
