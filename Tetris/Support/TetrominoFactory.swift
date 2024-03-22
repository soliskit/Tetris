//
//  TetrominoFactory.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrominoFactory {
    
    static func generate() -> Tetromino {
        let shapes = [
            // I Shape
            (
                shape: [
                    [false, false, false, false],
                    [false, false, false, false],
                    [true, true, true, true],
                    [false, false, false, false]
                ],
                color: Color.cyan,
                position: Position(row: 0, column: 3),
                rotations: [
                    [[false, false, false, false], [false, false, false, false], [true, true, true, true], [false, false, false, false]],
                    [[false, false, true, false], [false, false, true, false], [false, false, true, false], [false, false, true, false]]
                ]
            ),
            // O Shape
            (
                shape: [[true, true], [true, true]],
                color: Color.yellow,
                position: Position(row: 0, column: 4),
                rotations: [
                    [[true, true], [true, true]]
                ]
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
                rotations: [
                    [[false, true, false], [true, true, true], [false, false, false]],
                    [[false, true], [true, true], [false, true]],
                    [[false, false, false], [true, true, true], [false, true, false]],
                    [[true, false], [true, true], [true, false]]
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
                rotations: [
                    [[false, true, true], [true, true, false], [false, false, false]],
                    [[true, false], [true, true], [false, true]]
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
                rotations: [
                    [[true, true, false], [false, true, true], [false, false, false]],
                    [[false, true], [true, true], [true, false]]
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
                rotations: [
                    [[false, false, true], [true, true, true], [false, false, false]],
                    [[true, false], [true, false], [true, true]],
                    [[false, false, false], [true, true, true], [true, false, false]],
                    [[true, true], [false, true], [false, true]]
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
                rotations: [
                    [[false, false, true], [true, true, true], [false, false, false]],
                    [[true, false], [true, false], [true, true]],
                    [[false, false, false], [true, true, true], [true, false, false]],
                    [[true, true], [false, true], [false, true]]
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
            rotations: selectedShape.rotations
        )
    }
}
