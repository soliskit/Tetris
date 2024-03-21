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
    
    override func setUpWithError() throws {
        gameManager = GameManager()
    }
    
    override func tearDownWithError() throws {
        gameManager = nil
    }
    
    func testStartGame() {
        gameManager.startGame()
        XCTAssertEqual(gameManager.state, .playing, "Game state should be set to .playing when the game starts.")
        XCTAssertEqual(gameManager.score, 0, "Score should be reset to 0 at the start of a new game.")
        XCTAssertEqual(gameManager.level, 1, "Level should be set to 1 at the start of a new game.")
        XCTAssertTrue(isGameBoardInInitialState(gameManager.gameBoard), "Game board should be in its initial state at the start of a new game.")
        
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
        gameManager.startGame()
        let initialRotationState = gameManager.currentTetromino.rotationState
        gameManager.handleAction(.rotate)
        XCTAssertNotEqual(gameManager.currentTetromino.rotationState, initialRotationState)
    }
    
    func testHandleActionDrop() {
        // Assuming drop instantly moves the tetromino down by 1 row
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
    
    private func isGameBoardInInitialState(_ gameBoard: [[GameCell]]) -> Bool {
        for row in gameBoard {
            for cell in row {
                if cell.isFilled {
                    return false
                }
            }
        }
        return true
    }
}

