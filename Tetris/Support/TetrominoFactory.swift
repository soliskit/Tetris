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
                rotationPoints: [
                    [[-1, 1], [0, 1], [1, 1], [2, 1]],
                    [[1, -1], [1, 0], [1, 1], [1, 2]],
                    [[-1, 1], [0, 1], [1, 1], [2, 1]],
                    [[1, -1], [1, 0], [1, 1], [1, 2]]
                ],
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
                rotationPoints: [[[0, 0]]],
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
                rotationPoints: [
                    [[1, 0], [0, 1], [1, 1], [2, 1]],
                    [[1, 0], [1, 1], [1, 2], [2, 1]],
                    [[0, 1], [1, 1], [2, 1], [1, 2]],
                    [[1, 0], [0, 1], [1, 1], [1, 2]]
                ],
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)]
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
                rotationPoints: [
                    [[1, 0], [1, 1], [2, 1], [2, 2]],
                    [[2, 1], [1, 1], [1, 2], [0, 2]],
                    [[1, 0], [1, 1], [2, 1], [2, 2]],
                    [[2, 1], [1, 1], [1, 2], [0, 2]]
                ],
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)]
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
                rotationPoints: [
                    [[0, 0], [0, 1], [1, 1], [1, 2]],
                    [[2, 0], [1, 0], [1, 1], [0, 1]],
                    [[0, 0], [0, 1], [1, 1], [1, 2]],
                    [[2, 0], [1, 0], [1, 1], [0, 1]]
                ],
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)]
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
                rotationPoints: [
                    [[0, 0], [1, 0], [1, 1], [1, 2]],
                    [[0, 1], [0, 2], [1, 1], [2, 1]],
                    [[1, 0], [1, 1], [1, 2], [2, 2]],
                    [[0, 1], [1, 1], [2, 0], [2, 1]]
                ],
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)]
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
                rotationPoints: [
                    [[0, 1], [1, 0], [1, 1], [1, 2]],
                    [[0, 1], [1, 2], [1, 1], [2, 1]],
                    [[1, 2], [2, 1], [1, 1], [1, 0]],
                    [[2, 1], [1, 0], [1, 1], [0, 1]]
                ],
                wallKickData: [
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: -1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)],
                    [CGPoint(x: 0, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: 2), CGPoint(x: -1, y: 2)]
                ]
            )
        ]
        
        let randomIndex = Int.random(in: 0..<shapes.count)
        let selectedShape = shapes[randomIndex]
        
        return Tetromino(
            shape: selectedShape.shape,
            color: selectedShape.color,
            position: Position(row: 0, column: CGFloat(Int.random(in: 0...10))),
            rotationPoints: selectedShape.rotationPoints,
            wallKickData: selectedShape.wallKickData
        )
    }
}
