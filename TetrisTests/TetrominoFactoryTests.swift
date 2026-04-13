//
//  TetrominoFactoryTests.swift
//  TetrisTests
//
//  Created by David Solis on 4/11/26.
//

import Testing
@testable import Tetris

@Suite("Tetromino Factory")
@MainActor
struct TetrominoFactoryTests {

    @Test func generatesTetrominoWithNonEmptyShape() {
        let tetromino = TetrominoFactory.generate()
        #expect(!tetromino.shape.isEmpty)
        let hasAtLeastOneBlock = tetromino.shape.contains { row in
            row.contains(true)
        }
        #expect(hasAtLeastOneBlock)
    }

    @Test func generatedTetrominoHasRotations() {
        let tetromino = TetrominoFactory.generate()
        #expect(!tetromino.rotations.isEmpty)
    }

    @Test func generatedTetrominoHasWallKickData() {
        let tetromino = TetrominoFactory.generate()
        #expect(!tetromino.wallKickData.isEmpty)
    }

    @Test func generatedTetrominoStartsAtTopOfBoard() {
        let tetromino = TetrominoFactory.generate()
        #expect(tetromino.position.row == 0)
    }

    @Test func generatedTetrominoStartsNearCenter() {
        let tetromino = TetrominoFactory.generate()
        #expect(tetromino.position.column >= 3)
        #expect(tetromino.position.column <= 5)
    }

    @Test func generatedTetrominoFitsEmptyBoard() {
        let board: [[GameCell]] = Array(
            repeating: Array(repeating: GameCell(), count: 10),
            count: 20
        )
        let tetromino = TetrominoFactory.generate()
        #expect(tetromino.fitsWithin(gameBoard: board))
    }

    @Test func generatedTetrominoStartsAtRotationStateZero() {
        let tetromino = TetrominoFactory.generate()
        #expect(tetromino.rotationState == 0)
    }

    @Test func shapeMatchesFirstRotation() {
        let tetromino = TetrominoFactory.generate()
        #expect(tetromino.shape == tetromino.rotations[0])
    }

    @Test func multipleGenerationsProduceDifferentPieces() {
        var shapes = Set<String>()
        for _ in 0..<100 {
            let tetromino = TetrominoFactory.generate()
            let description = tetromino.shape.description
            shapes.insert(description)
        }
        #expect(shapes.count > 1)
    }
}
