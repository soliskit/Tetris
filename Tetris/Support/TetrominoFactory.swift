//
//  TetrominoFactory.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

/// Factory responsible for generating Tetromino instances with predefined shapes and properties.
struct TetrominoFactory {
    
    /// Generates a random Tetromino with predefined shapes, colors, rotation points, and wall kick data.
    /// - Returns: A `Tetromino` instance with randomized shape and initial properties.
    static func generate() -> Tetromino {
        let shapes = [
            // I Shape
            (
                shape: [
                    [false, false, false, false],
                    [true, true, true, true],
                    [false, false, false, false],
                    [false, false, false, false]
                ],
                color: Color.cyan,
                position: Position(row: 0, column: 3),
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -2, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: -2, y: 1), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 2, y: 0), CGPoint(x: -1, y: -2), CGPoint(x: 2, y: 1)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 2, y: -1), CGPoint(x: -1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: -2, y: 0), CGPoint(x: 1, y: 2), CGPoint(x: -2, y: -1)]
                ]
            ),
            // O Shape
            (
                shape: [[true, true], [true, true]],
                color: Color.yellow,
                position: Position(row: 0, column: 4),
                wallKickData: [[CGPoint.zero]]
            ),
            // T Shape
            (
                shape: [
                    [false, true, false],
                    [true, true, true],
                    [false, false, false]
                ],
                color: Color.purple,
                position: Position(row: 0, column: 4),
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)]
                ]
            ),
            // S Shape
            (
                shape: [
                    [false, true, true],
                    [true, true, false],
                    [false, false, false]
                ],
                color: Color.green,
                position: Position(row: 0, column: 4),
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)]
                ]
            ),
            // Z Shape
            (
                shape: [
                    [true, true, false],
                    [false, true, true],
                    [false, false, false]
                ],
                color: Color.red,
                position: Position(row: 0, column: 4),
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)]
                ]
            ),
            // J Shape
            (
                shape: [
                    [true, false, false],
                    [true, true, true],
                    [false, false, false]
                ],
                color: Color.blue,
                position: Position(row: 0, column: 4),
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 2, y: 0), CGPoint(x: 2, y: -1)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2), CGPoint(x: -2, y: 0), CGPoint(x: -2, y: 1)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2), CGPoint(x: -2, y: 0), CGPoint(x: -2, y: -1)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2), CGPoint(x: 2, y: 0), CGPoint(x: 2, y: 1)]
                ]
            ),
            // L Shape
            (
                shape: [
                    [false, false, true],
                    [true, true, true],
                    [false, false, false]
                ],
                color: Color.orange,
                position: Position(row: 0, column: 4),
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 2, y: 0), CGPoint(x: 2, y: -1)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2), CGPoint(x: -2, y: 0), CGPoint(x: -2, y: 1)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2), CGPoint(x: -2, y: 0), CGPoint(x: -2, y: -1)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2), CGPoint(x: 2, y: 0), CGPoint(x: 2, y: 1)]
                ]
            )
        ]
        guard let selectedShape = shapes.randomElement() else {
            fatalError("Unable to generate Tetromino")
        }
        
        return Tetromino(
            shape: selectedShape.shape,
            color: selectedShape.color,
            position: selectedShape.position,
            wallKickData: selectedShape.wallKickData
        )
    }
}
