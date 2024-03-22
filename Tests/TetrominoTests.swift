//
//  TetrominoTests.swift
//  TetrisTests
//
//  Created by David Solis on 3/22/24.
//

import XCTest
@testable import Tetris

final class TetrominoTests: XCTestCase {
    var tetromino: Tetromino!
    var gameBoard: [[GameCell?]]!

    override func setUpWithError() throws {
        tetromino = Tetromino(shape: [[true]], color: .red, position: Position(row: 0, column: 0), rotations: [[[true]]], wallKickData: [[Position(row: 0, column: 0)]])
        gameBoard = Array(repeating: Array(repeating: nil, count: 10), count: 20)
    }

    override func tearDownWithError() throws {
        tetromino = nil
        gameBoard = nil
    }
    
    func testRotate() {
        let originalShape = tetromino.shape
        let originalRotationState = tetromino.rotationState
        
        tetromino.rotate(gameBoard: gameBoard)
        
        let rotatedShape = tetromino.shape
        let rotatedRotationState = tetromino.rotationState
        
        if originalShape != rotatedShape {
            XCTAssertNotEqual(originalRotationState, rotatedRotationState, "The rotation state should change after rotation.")
        } else {
            XCTAssertEqual(originalRotationState, rotatedRotationState, "The rotation state should not change if the shape does not change.")
        }
    }

    
    func testFitsWithin() {
        let expectedFit = true
        let doesFit = tetromino.fitsWithin(gameBoard: gameBoard)
        
        XCTAssertEqual(doesFit, expectedFit, "The tetromino fit within the game board should be \(expectedFit).")
        
        let tetrominoX = Int(tetromino.position.column)
        let tetrominoY = Int(tetromino.position.row)
        gameBoard[tetrominoY][tetrominoX] = GameCell(isFilled: true, color: .blue)
        
        let expectedFitAfterFillingCell = false
        let doesFitAfterFillingCell = tetromino.fitsWithin(gameBoard: gameBoard)
        
        XCTAssertEqual(doesFitAfterFillingCell, expectedFitAfterFillingCell, "After filling a cell that the tetromino occupies, the tetromino fit within the game board should be \(expectedFitAfterFillingCell).")
    }
}
