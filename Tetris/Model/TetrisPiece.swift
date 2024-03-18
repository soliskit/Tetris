//
//  TetrisPiece.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct Block: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
    var isLocked: Bool = false
    let parentPieceID: UUID
}

struct TetrisPiece {
    let id = UUID()
    var shape: [[Bool]]
    var position: CGPoint
    var color: Color
    var rotations: [[[Bool]]]
    var rotationIndex: Int = 0
    
    init(position: CGPoint, color: Color, rotations: [[[Bool]]]) {
        self.position = position
        self.color = color
        self.rotations = rotations
        self.shape = rotations[0]
    }
    
    mutating func rotate() {
        rotationIndex = (rotationIndex + 1) % rotations.count
        shape = rotations[rotationIndex]
    }
    
    func generateBlocks(position: CGPoint? = nil) -> [Block] {
        let effectivePosition = position ?? self.position
        let blockPositions = shape.enumerated().flatMap { y, row -> [(x: CGFloat, y: CGFloat, blockExists: Bool)] in
            row.enumerated().map { x, blockExists in
                (x: CGFloat(x), y: CGFloat(y), blockExists: blockExists)
            }
        }
        
        return blockPositions.filter { $0.blockExists }.map { pos in
            let absolutePosition = CGPoint(x: pos.x + effectivePosition.x, y: pos.y + effectivePosition.y)
            return Block(x: absolutePosition.x, y: absolutePosition.y, color: color, parentPieceID: id)
        }
    }

}
