//
//  TetrominoFactory.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrominoFactory {
    
    static func generate() -> Tetromino {
        let tetronimos: [Tetromino] = [
            // I Shape
            Tetromino(
                shape: [
                    [false, false, false, false],
                    [false, false, false, false],
                    [true, true, true, true],
                    [false, false, false, false]
                ],
                color: CustomColor(from: .cyan),
                position: Position(row: 0, column: 3),
                rotations: [
                    [[false, false, false, false], [false, false, false, false], [true, true, true, true], [false, false, false, false]],
                    [[false, false, true, false], [false, false, true, false], [false, false, true, false], [false, false, true, false]]
                ],
                wallKickData: [
                    [Position(row: 0, column: -1), Position(row: 0, column: 2), Position(row: -1, column: 2), Position(row: 2, column: -1)],
                    [Position(row: 0, column: 1), Position(row: 0, column: -2), Position(row: 1, column: -2), Position(row: -2, column: 1)],
                    [Position(row: 0, column: 2), Position(row: 0, column: -1), Position(row: 1, column: -1), Position(row: -2, column: 2)],
                    [Position(row: 0, column: -2), Position(row: 0, column: 1), Position(row: -1, column: 1), Position(row: 2, column: -2)]
                ]
            ),
            // O Shape
            Tetromino(
                shape: [[true, true], [true, true]],
                color: CustomColor(from: .yellow),
                position: Position(row: 0, column: 4),
                rotations: [
                    [[true, true], [true, true]]
                ],
                wallKickData: [
                    [Position(row: 0, column: 0)]
                ]
            ),
            // T Shape
            Tetromino(
                shape: [
                    [false, true, false],
                    [true, true, true],
                    [false, false, false]
                ],
                color: CustomColor(from: .purple),
                position: Position(row: 0, column: 4),
                rotations: [
                    [[false, true, false], [true, true, true], [false, false, false]],
                    [[false, true], [true, true], [false, true]],
                    [[false, false, false], [true, true, true], [false, true, false]],
                    [[true, false], [true, true], [true, false]]
                ],
                wallKickData: [
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: -1, column: -1), Position(row: 2, column: 0), Position(row: 2, column: -1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: -1, column: 1), Position(row: 2, column: 0), Position(row: 2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: -1, column: 1), Position(row: 2, column: 0), Position(row: 2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: -1, column: -1), Position(row: 2, column: 0), Position(row: 2, column: -1)]
                ]),
            // S Shape
            Tetromino(
                shape: [
                    [false, true, true],
                    [true, true, false],
                    [false, false, false]
                ],
                color: CustomColor(from: .green),
                position: Position(row: 0, column: 4),
                rotations: [
                    [[false, true, true], [true, true, false], [false, false, false]],
                    [[true, false], [true, true], [false, true]]
                ],
                wallKickData: [
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: 1, column: -1), Position(row: -2, column: 0), Position(row: -2, column: -1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: -1, column: 1), Position(row: 2, column: 0), Position(row: 2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: 1, column: 1), Position(row: -2, column: 0), Position(row: -2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: -1, column: -1), Position(row: 2, column: 0), Position(row: 2, column: -1)]
                ]
            ),
            // Z Shape
            Tetromino(
                shape: [
                    [true, true, false],
                    [false, true, true],
                    [false, false, false]
                ],
                color: CustomColor(from: .red),
                position: Position(row: 0, column: 4),
                rotations: [
                    [[true, true, false], [false, true, true], [false, false, false]],
                    [[false, true], [true, true], [true, false]]
                ],
                wallKickData: [
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: 1, column: -1), Position(row: -2, column: 0), Position(row: -2, column: -1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: -1, column: 1), Position(row: 2, column: 0), Position(row: 2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: 1, column: 1), Position(row: -2, column: 0), Position(row: -2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: -1, column: -1), Position(row: 2, column: 0), Position(row: 2, column: -1)]
                ]
            ),
            // J Shape
            Tetromino(
                shape: [
                    [true, false, false],
                    [true, true, true],
                    [false, false, false]
                ],
                color: CustomColor(from: .blue),
                position: Position(row: 0, column: 4),
                rotations: [
                    [[false, false, true], [true, true, true], [false, false, false]],
                    [[true, false], [true, false], [true, true]],
                    [[false, false, false], [true, true, true], [true, false, false]],
                    [[true, true], [false, true], [false, true]]
                ],
                wallKickData: [
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: 1, column: -1), Position(row: -2, column: 0), Position(row: -2, column: -1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: -1, column: 1), Position(row: 2, column: 0), Position(row: 2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: 1, column: 1), Position(row: -2, column: 0), Position(row: -2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: -1, column: -1), Position(row: 2, column: 0), Position(row: 2, column: -1)]
                ]
            ),
            // L Shape
            Tetromino(
                shape: [
                    [false, false, true],
                    [true, true, true],
                    [false, false, false]
                ],
                color: CustomColor(from: .orange),
                position: Position(row: 0, column: 4),
                rotations: [
                    [[false, false, true], [true, true, true], [false, false, false]],
                    [[true, false], [true, false], [true, true]],
                    [[false, false, false], [true, true, true], [true, false, false]],
                    [[true, true], [false, true], [false, true]]
                ],
                wallKickData: [
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: 1, column: -1), Position(row: -2, column: 0), Position(row: -2, column: -1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: -1, column: 1), Position(row: 2, column: 0), Position(row: 2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: 1, column: 1), Position(row: -2, column: 0), Position(row: -2, column: 1)],
                    [Position(row: 0, column: 0), Position(row: 0, column: -1), Position(row: -1, column: -1), Position(row: 2, column: 0), Position(row: 2, column: -1)]
                ]
            )
        ]
        guard let selectedTetronimo = tetronimos.randomElement() else {
            fatalError("Unable to generate Tetromino")
        }
        return selectedTetronimo
    }
}
