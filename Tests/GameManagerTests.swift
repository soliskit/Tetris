//
//  GameManagerTests.swift
//  TetrisTests
//
//  Created by David Solis on 3/17/24.
//

import XCTest
@testable import Tetris

class GameManagerTests: XCTestCase {
    var gameManager: GameManager!
    var gameBoard: [[GameCell?]]!
    
    override func setUpWithError() throws {
        gameManager = GameManager()
        gameBoard = Array(repeating: Array(repeating: nil, count: 10), count: 20)
    }
    
    override func tearDownWithError() throws {
        gameManager = nil
        gameBoard = nil
    }
    
    func testStartGame() {
        gameManager.startGame()
        XCTAssertEqual(gameManager.state, .playing, "Game state should be set to .playing when the game starts.")
        XCTAssertEqual(gameManager.score, 0, "Score should be reset to 0 at the start of a new game.")
        XCTAssertEqual(gameManager.level, 1, "Level should be set to 1 at the start of a new game.")
        
        XCTAssertNotNil(gameManager.currentTetromino, "There should be a current tetromino at the start of the game.")
        XCTAssertNotNil(gameManager.nextTetromino, "There should be a next tetromino defined at the start of the game.")
    }

    func testHandleActionMoveLeft() {
        gameManager.startGame()
        let initialColumn = gameManager.currentTetromino.position.column
        gameManager.handleAction(.moveLeft)
        XCTAssertEqual(gameManager.currentTetromino.position.column, initialColumn - 1)
    }
    
    func testHandleActionMoveRight() {
        gameManager.startGame()
        let initialColumn = gameManager.currentTetromino.position.column
        gameManager.handleAction(.moveRight)
        XCTAssertEqual(gameManager.currentTetromino.position.column, initialColumn + 1)
    }

    func testHandleActionHold() {
        gameManager.startGame()
        let initialTetromino = gameManager.currentTetromino
        gameManager.handleAction(.hold)
        XCTAssertNotNil(gameManager.heldTetromino)
        XCTAssertEqual(gameManager.heldTetromino?.id, initialTetromino.id)
        // Further checks might be necessary depending on how hold functionality is implemented
    }
    
    func testHandleActionRotate() {
        let originalTetromino = gameManager.currentTetromino
        guard let originalBoard = gameBoard else { fatalError("gameBoard failed to initialize") }
        gameManager.startGame()
        
        gameManager.handleAction(.rotate)
        
        let rotatedTetromino = gameManager.currentTetromino
        XCTAssertNotEqual(originalTetromino.shape, rotatedTetromino.shape, "The tetromino shape should change after rotation.")
        XCTAssertEqual(originalTetromino.position, rotatedTetromino.position, "The tetromino position should not change after rotation.")
        
        XCTAssertTrue(isGameBoardInInitialState(gameBoard), "The game board should be in its initial state.")
        
        XCTAssertTrue(verifyTetrominoPlacement(rotatedTetromino, on: gameBoard), "The tetromino should be placed correctly on the game board.")
        
        XCTAssertTrue(verifyNoUnintendedGameBoardChanges(originalBoard, gameBoard, excludingTetromino: rotatedTetromino), "There should be no unintended changes on the game board.")
    }
    
    func testHandleActionDrop() {
        gameManager.startGame()
        let initialRow = gameManager.currentTetromino.position.row
        gameManager.handleAction(.drop)
        XCTAssertEqual(gameManager.currentTetromino.position.row, initialRow + 1)
    }
    
    func testHandleActionPauseAndResume() {
        gameManager.startGame()
        gameManager.handleAction(.pause)
        XCTAssertEqual(gameManager.state, .paused)
        
        gameManager.handleAction(.resume)
        XCTAssertEqual(gameManager.state, .playing)
    }
    
    private func isGameBoardInInitialState(_ gameBoard: [[GameCell?]]) -> Bool {
        for row in gameBoard {
            for cell in row {
                if cell?.isFilled == true {
                    return false
                }
            }
        }
        return true
    }
    
    private func verifyTetrominoPlacement(_ tetromino: Tetromino, on gameBoard: [[GameCell?]]) -> Bool {
        return !tetromino.shape.enumerated().contains { y, row in
            row.enumerated().contains { x, isFilled in
                guard isFilled else { return false }
                return !tetromino.fitsWithin(gameBoard: gameBoard)
            }
        }
    }

    private func verifyNoUnintendedGameBoardChanges(_ originalBoard: [[GameCell?]], _ newBoard: [[GameCell?]], excludingTetromino tetromino: Tetromino) -> Bool {
        return newBoard.indices.first(where: { y in
            newBoard[y].indices.first(where: { x in
                !tetromino.fitsWithin(gameBoard: newBoard) && originalBoard[y][x]?.isFilled != newBoard[y][x]?.isFilled
            }) != nil
        }) == nil
    }
}
