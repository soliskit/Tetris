//
//  TetrisPieceFactory.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import Foundation

struct TetrisPieceFactory {
    static func createPiece(columns: Int) -> TetrisPiece {
        let pieces = [
            // I Piece
            TetrisPiece(position: CGPoint(x: columns / 2 - 2, y: 0), color: .cyan, rotations: [
                [[true, true, true, true]],
                [[true], [true], [true], [true]]
            ]),
            // O Piece
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .yellow, rotations: [
                [[true, true], [true, true]]
            ]),
            // T Piece
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .purple, rotations: [
                [[false, true, false], [true, true, true]],
                [[true, false], [true, true], [true, false]],
                [[true, true, true], [false, true, false]],
                [[false, true], [true, true], [false, true]]
            ]),
            // S Piece
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .green, rotations: [
                [[false, true, true], [true, true, false]],
                [[true, false], [true, true], [false, true]]
            ]),
            // Z Piece
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .red, rotations: [
                [[true, true, false], [false, true, true]],
                [[false, true], [true, true], [true, false]]
            ]),
            // J Piece
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .blue, rotations: [
                [[true, false, false], [true, true, true]],
                [[true, true], [true, false], [true, false]],
                [[true, true, true], [false, false, true]],
                [[false, true], [false, true], [true, true]]
            ]),
            // L Piece
            TetrisPiece(position: CGPoint(x: columns / 2 - 1, y: 0), color: .orange, rotations: [
                [[false, false, true], [true, true, true]],
                [[true, false], [true, false], [true, true]],
                [[true, true, true], [true, false, false]],
                [[true, true], [false, true], [false, true]]
            ])
        ]
        
        return pieces.randomElement()!
    }
}
