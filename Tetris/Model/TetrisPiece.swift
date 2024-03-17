//
//  TetrisPiece.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

/// Represents a single block (the smallest unit) of a Tetris piece.
struct Block: Identifiable {
    /// Unique identifier for each block to conform to the Identifiable protocol.
    let id = UUID()
    /// X-coordinate of the block on the game board.
    var x: Int
    /// Y-coordinate of the block on the game board.
    var y: Int
    /// The color of the block, used for rendering in the UI.
    let color: Color
    /// Identifier of the Tetris piece this block belongs to./
    var parentPieceID: UUID
}

/// Represents a Tetris piece, which is composed of multiple blocks.
struct TetrisPiece {
    /// Unique identifier for each Tetris piece.
    var id = UUID()
    /// 2D array representing the shape of the piece in its current rotation. True indicates a block is present./
    var shape: [[Bool]]
    /// The position of the piece on the game board, usually tracked by the top-left corner.
    var position: CGPoint
    /// The color of the piece, applied to all of its blocks.
    var color: Color
    /// All possible rotations of the piece, each represented as a 2D array like `shape`.
    var rotations: [[[Bool]]]
    /// The index of the current rotation within the `rotations` array.
    var rotationIndex: Int = 0
    
    /// Initializes a new Tetris piece with its position, color, and possible rotations.
    init(position: CGPoint, color: Color, rotations: [[[Bool]]]) {
        self.position = position
        self.color = color
        self.rotations = rotations
        /// Start with the first rotation shape.
        self.shape = rotations[0]
    }
    
    /// Rotates the piece to its next rotation state. This updates the `shape` of the piece based on `rotationIndex`.
    mutating func rotate() {
        rotationIndex = (rotationIndex + 1) % rotations.count // Cycle through the rotations.
        shape = rotations[rotationIndex] // Update the shape to the new rotation.
    }
    
    /// Generates and returns a collection of `Block` instances that represent the piece's current state.
    func generateBlocks() -> [Block] {
        // Flatten the shape into a collection of tuples (x, y, blockExists), including their indices.
        let blockPositions = shape.enumerated().flatMap { y, row -> [(x: Int, y: Int, blockExists: Bool)] in
            row.enumerated().map { x, blockExists in
                // Map each block's existence and its grid position.
                (x: x, y: y, blockExists: blockExists)
            }
        }
        
        // Filter out positions where `blockExists` is false, then map the rest to `Block` objects.
        return blockPositions.filter { $0.blockExists }.map { pos in
            // Calculate the absolute position on the board, taking the piece's position into account.
            let absolutePosition = CGPoint(x: pos.x + Int(position.x), y: pos.y + Int(position.y))
            // Create a `Block` for each true value in the piece's shape, assigning it the calculated absolute position, the piece's color, and its parent piece ID.
            return Block(x: Int(absolutePosition.x), y: Int(absolutePosition.y), color: color, parentPieceID: id)
        }
    }
    
    /// Generates a list of blocks with their positions transformed based on the piece's current position.
    func transformedBlocks(position: CGPoint) -> [Block] {
        shape.enumerated().flatMap { y, row in
            row.enumerated().compactMap { x, isBlock in
                guard isBlock else { return nil }
                return Block(x: x + Int(position.x), y: y + Int(position.y), color: color, parentPieceID: id)
            }
        }
    }
}
