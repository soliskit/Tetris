//
//  TetrisPiece.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct Block: Identifiable {
    let id = UUID()
    var x: Int
    var y: Int
    let color: Color
    var parentPieceID: UUID
}

struct TetrisPiece {
    var id = UUID()
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
    
    func generateBlocks() -> [Block] {
        let blockPositions = shape.enumerated().flatMap { y, row -> [(x: Int, y: Int, blockExists: Bool)] in
            row.enumerated().map { x, blockExists in
                (x: x, y: y, blockExists: blockExists)
            }
        }
        
        return blockPositions.filter { $0.blockExists }.map { pos in
            let absolutePosition = CGPoint(x: pos.x + Int(position.x), y: pos.y + Int(position.y))
            return Block(x: Int(absolutePosition.x), y: Int(absolutePosition.y), color: color, parentPieceID: id)
        }
    }
    
    func transformedBlocks(position: CGPoint) -> [Block] {
        shape.enumerated().flatMap { y, row in
            row.enumerated().compactMap { x, isBlock in
                guard isBlock else { return nil }
                return Block(x: x + Int(position.x), y: y + Int(position.y), color: color, parentPieceID: id)
            }
        }
    }
}
