//
//  TetrominoTests.swift
//  TetrisTests
//
//  Created by David Solis on 4/11/26.
//

import Testing
@testable import Tetris

@MainActor
@Suite("Tetromino")
struct TetrominoTests {

    let emptyBoard: [[GameCell]] = Array(
        repeating: Array(repeating: GameCell(), count: 10),
        count: 20
    )

    @Test func fitsWithinEmptyBoard() {
        let tetromino = TetrominoFactory.generate()
        #expect(tetromino.fitsWithin(gameBoard: emptyBoard))
    }

    @Test func doesNotFitBelowBoard() {
        var tetromino = TetrominoFactory.generate()
        tetromino.position = Position(row: 20, column: 4)
        #expect(!tetromino.fitsWithin(gameBoard: emptyBoard))
    }

    @Test func doesNotFitLeftOfBoard() {
        var tetromino = TetrominoFactory.generate()
        tetromino.position = Position(row: 0, column: -5)
        #expect(!tetromino.fitsWithin(gameBoard: emptyBoard))
    }

    @Test func doesNotFitRightOfBoard() {
        var tetromino = TetrominoFactory.generate()
        tetromino.position = Position(row: 0, column: 12)
        #expect(!tetromino.fitsWithin(gameBoard: emptyBoard))
    }

    @Test func doesNotFitOnFilledCell() {
        var board = emptyBoard
        board[1][4] = GameCell(isFilled: true, color: CustomColor(from: .red))

        let tetromino = Tetromino(
            shape: [[true]],
            color: CustomColor(from: .blue),
            position: Position(row: 1, column: 4),
            rotations: [[[true]]],
            wallKickData: [[Position(row: 0, column: 0)]]
        )
        #expect(!tetromino.fitsWithin(gameBoard: board))
    }

    @Test func fitsOnEmptyCellNextToFilledCell() {
        var board = emptyBoard
        board[1][4] = GameCell(isFilled: true, color: CustomColor(from: .red))

        let tetromino = Tetromino(
            shape: [[true]],
            color: CustomColor(from: .blue),
            position: Position(row: 1, column: 5),
            rotations: [[[true]]],
            wallKickData: [[Position(row: 0, column: 0)]]
        )
        #expect(tetromino.fitsWithin(gameBoard: board))
    }

    @Test func rotationChangesShape() {
        var tetromino = Tetromino(
            shape: [
                [false, true, false],
                [true, true, true],
                [false, false, false]
            ],
            color: CustomColor(from: .purple),
            position: Position(row: 5, column: 4),
            rotations: [
                [[false, true, false], [true, true, true], [false, false, false]],
                [[false, true], [true, true], [false, true]],
                [[false, false, false], [true, true, true], [false, true, false]],
                [[true, false], [true, true], [true, false]]
            ],
            wallKickData: [
                [Position(row: 0, column: 0)],
                [Position(row: 0, column: 0)],
                [Position(row: 0, column: 0)],
                [Position(row: 0, column: 0)]
            ]
        )

        let originalShape = tetromino.shape
        tetromino.rotate(gameBoard: emptyBoard)
        #expect(tetromino.shape != originalShape)
        #expect(tetromino.rotationState == 1)
    }

    @Test func rotationCyclesBackToOriginal() {
        var tetromino = Tetromino(
            shape: [[true, true], [true, true]],
            color: CustomColor(from: .yellow),
            position: Position(row: 5, column: 4),
            rotations: [[[true, true], [true, true]]],
            wallKickData: [[Position(row: 0, column: 0)]]
        )

        let originalShape = tetromino.shape
        tetromino.rotate(gameBoard: emptyBoard)
        #expect(tetromino.shape == originalShape)
    }

    @Test func identifiableHasUniqueIds() {
        let a = TetrominoFactory.generate()
        let b = TetrominoFactory.generate()
        #expect(a.id != b.id)
    }
}
