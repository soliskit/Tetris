//
//  TetrisPieceFactory.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import Foundation

/// `TetrisPieceFactory` is responsible for creating Tetris pieces with predefined shapes and colors.
struct TetrisPieceFactory {
    /// Creates a random Tetris piece.
    /// - Parameter columns: The number of columns in the game board. This parameter helps position the piece correctly when spawned.
    /// - Returns: A randomly selected `TetrisPiece` with predefined rotations and a starting position.
    static func createPiece(columns: Int) -> TetrisPiece {
        let pieces = [
            // I Piece - Straight line.
            TetrisPiece(position: CGPoint(x: columns / 2 - 2, y: 0), color: .cyan, rotations: [
                [[true, true, true, true]],
                [[true], [true], [true], [true]]
            ]),
            // O Piece - Square block.
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .yellow, rotations: [
                [[true, true], [true, true]]
            ]),
            // T Piece - T-shaped block.
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .purple, rotations: [
                [[false, true, false], [true, true, true]],
                [[true, false], [true, true], [true, false]],
                [[true, true, true], [false, true, false]],
                [[false, true], [true, true], [false, true]]
            ]),
            // S Piece - S-shaped zigzag.
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .green, rotations: [
                [[false, true, true], [true, true, false]],
                [[true, false], [true, true], [false, true]]
            ]),
            // Z Piece - Z-shaped zigzag.
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .red, rotations: [
                [[true, true, false], [false, true, true]],
                [[false, true], [true, true], [true, false]]
            ]),
            // J Piece - J-shaped block.
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .blue, rotations: [
                [[true, false, false], [true, true, true]],
                [[true, true], [true, false], [true, false]],
                [[true, true, true], [false, false, true]],
                [[false, true], [false, true], [true, true]]
            ]),
            // L Piece - L-shaped block.
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .orange, rotations: [
                [[false, false, true], [true, true, true]],
                [[true, false], [true, false], [true, true]],
                [[true, true, true], [true, false, false]],
                [[true, true], [false, true], [false, true]]
            ])
        ]
        // Randomly selects one of the predefined pieces to return
        return pieces.randomElement()!
    }
}
