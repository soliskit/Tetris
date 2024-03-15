//
//  TetrisPiece.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrisPiece {
    var shape: [[Bool]]
    var position: CGPoint
    var color: Color
    var rotations: [[[Bool]]]
    var rotationIndex: Int = 0
    
    init(position: CGPoint, color: Color, rotations: [[[Bool]]]) {
        self.position = position
        self.color = color
        self.rotations = rotations
        self.shape = rotations[0] // Start with the first rotation
    }
    
    mutating func rotate() {
        rotationIndex = (rotationIndex + 1) % rotations.count
        shape = rotations[rotationIndex]
    }
}
