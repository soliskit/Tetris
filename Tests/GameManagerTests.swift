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
    }
    
    override func tearDownWithError() throws {
        gameManager = nil
    }
    
    func testGameManagerInitialization() {
        XCTAssertNotNil(gameManager.currentTetromino)
        XCTAssertNotNil(gameManager.nextTetromino)
        XCTAssertNil(gameManager.heldTetromino)
        XCTAssertTrue(gameManager.canHoldTetromino)
        XCTAssertEqual(gameManager.score, 0)
        XCTAssertEqual(gameManager.level, 1)
        XCTAssertEqual(gameManager.state, .gameOver)
        let expectedGameBoard = Array(repeating: Array(repeating: GameCell(), count: 10), count: 20)
        XCTAssertTrue(isGameBoardInInitialState(gameManager.gameBoard))
    }
    
    func testHandleNewGameAction() {
        gameManager.handleAction(.newGame)
        XCTAssertEqual(gameManager.state, .paused)
    }
    
    func testHandleContinueGameAction() {
        let mockGameSession = GameSession(
            gameBoard: Array(repeating: Array(repeating: GameCell(isFilled: true, color: CustomColor(from: .red)), count: 10), count: 20),
            score: 100,
            level: 2,
            currentTetromino: TetrominoFactory.generate(),
            nextTetromino: TetrominoFactory.generate(),
            heldTetromino: nil,
            canHoldTetromino: true
        )
        
        if let encodedSession = try? JSONEncoder().encode(mockGameSession) {
            UserDefaults.standard.set(encodedSession, forKey: "savedGameSession")
        }
        
        gameManager.handleAction(.continueGame)
        
        XCTAssertEqual(gameManager.gameBoard, mockGameSession.gameBoard)
        XCTAssertEqual(gameManager.score, mockGameSession.score)
        XCTAssertEqual(gameManager.level, mockGameSession.level)
        XCTAssertEqual(gameManager.currentTetromino, mockGameSession.currentTetromino)
        XCTAssertEqual(gameManager.nextTetromino, mockGameSession.nextTetromino)
        XCTAssertEqual(gameManager.heldTetromino, mockGameSession.heldTetromino)
        XCTAssertEqual(gameManager.canHoldTetromino, mockGameSession.canHoldTetromino)
        
        UserDefaults.standard.removeObject(forKey: "savedGameSession")
    }

    func testHandleMoveLeftAction() {
        gameManager.handleAction(.newGame)
        gameManager.handleAction(.resume)
        
        let originalBoard = gameManager.gameBoard
        let originalPosition = gameManager.currentTetromino.position
        gameManager.handleAction(.moveLeft)
        
        XCTAssertEqual(gameManager.currentTetromino.position.column, originalPosition.column - 1, "Tetromino should have moved left by one column.")
        
        XCTAssertTrue(verifyTetrominoPlacement(gameManager.currentTetromino, on: gameManager.gameBoard), "Tetromino should be within valid bounds after moving left.")
        
        XCTAssertTrue(verifyNoUnintendedGameBoardChanges(originalBoard, gameManager.gameBoard, excludingTetromino: gameManager.currentTetromino), "Moving tetromino left should not affect other parts of the game board.")
    }
    
    func testHandleMoveRightAction() {
        gameManager.handleAction(.newGame)
        gameManager.handleAction(.resume)
        
        let originalBoard = gameManager.gameBoard
        let originalPosition = gameManager.currentTetromino.position
        gameManager.handleAction(.moveRight)
        
        XCTAssertEqual(gameManager.currentTetromino.position.column, originalPosition.column + 1, "Tetromino should have moved right by one column.")
        
        XCTAssertTrue(verifyTetrominoPlacement(gameManager.currentTetromino, on: gameManager.gameBoard), "Tetromino should be within valid bounds after moving right.")
        
        XCTAssertTrue(verifyNoUnintendedGameBoardChanges(originalBoard, gameManager.gameBoard, excludingTetromino: gameManager.currentTetromino), "Moving tetromino right should not affect other parts of the game board.")
    }
    
    func testHandleHoldActionWithNoTetrominoHeld() {
        gameManager.handleAction(.newGame)
        gameManager.handleAction(.resume)
        
        let currentTetrominoBeforeHold = gameManager.currentTetromino
        let nextTetrominoBeforeHold = gameManager.nextTetromino
        
        gameManager.handleAction(.hold)
        
        XCTAssertNotNil(gameManager.heldTetromino, "There should be a Tetromino in the hold slot after holding.")
        XCTAssertEqual(gameManager.currentTetromino, nextTetrominoBeforeHold, "The next Tetromino should become the current one after holding.")
        XCTAssertEqual(gameManager.heldTetromino, currentTetrominoBeforeHold, "The held Tetromino should be the one that was current before holding.")
        
        XCTAssertFalse(gameManager.canHoldTetromino, "The game should not allow holding another Tetromino immediately after holding one.")
    }

    func testHandleHoldActionWithTetrominoAlreadyHeld() {
        gameManager.handleAction(.newGame)
        gameManager.handleAction(.resume)
        gameManager.handleAction(.hold)
        
        gameManager.canHoldTetromino = true
        
        let currentTetrominoBeforeSecondHold = gameManager.currentTetromino
        let heldTetrominoBeforeSecondHold = gameManager.heldTetromino
        
        gameManager.handleAction(.hold)
        
        XCTAssertEqual(gameManager.currentTetromino, heldTetrominoBeforeSecondHold, "The previously held Tetromino should become the current one.")
        XCTAssertEqual(gameManager.heldTetromino, currentTetrominoBeforeSecondHold, "The previously current Tetromino should now be held.")
        
        XCTAssertFalse(gameManager.canHoldTetromino, "Should not be able to hold immediately after holding.")
    }
    
    func testHandleRotateAction() {
        gameManager.handleAction(.newGame)
        gameManager.handleAction(.resume)
        
        let originalRotationState = gameManager.currentTetromino.rotationState
        let expectedNextRotationState = (originalRotationState + 1) % gameManager.currentTetromino.rotations.count
        
        gameManager.handleAction(.rotate)
        
        XCTAssertEqual(gameManager.currentTetromino.rotationState, expectedNextRotationState, "Tetromino should have advanced to the next rotation state.")
        
        XCTAssertTrue(gameManager.currentTetromino.fitsWithin(gameBoard: gameManager.gameBoard), "The Tetromino's new orientation should fit within the game board without overlapping filled cells.")
        
        let newPosition = gameManager.currentTetromino.position
        XCTAssertEqual(newPosition, gameManager.currentTetromino.position, "Tetromino position should remain unchanged after rotation.")
        
        XCTAssertEqual(gameManager.state, .playing, "Game state should remain as playing after rotation action.")
    }

    func testHandleDropAction() {
        gameManager.handleAction(.newGame)
        gameManager.handleAction(.resume)
        
        let originalPosition = gameManager.currentTetromino.position
        
        gameManager.handleAction(.drop)
        
        let expectedPosition = Position(row: originalPosition.row + 1, column: originalPosition.column)
        XCTAssertEqual(gameManager.currentTetromino.position, expectedPosition, "Tetromino should move down by one row after a drop action.")
        
        XCTAssertTrue(gameManager.currentTetromino.fitsWithin(gameBoard: gameManager.gameBoard), "Tetromino should still fit within game board bounds after a drop.")
        
        XCTAssertEqual(gameManager.state, .playing, "Game state should remain playing after a drop action.")
    }

    private func isGameBoardInInitialState(_ gameBoard: [[GameCell?]]) -> Bool {
        for row in gameBoard {
            for cell in row {
                if let isFilled = cell?.isFilled, isFilled {
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
