//
//  GameManagerTests.swift
//  TetrisTests
//
//  Created by David Solis on 4/11/26.
//

import Testing
@testable import Tetris

@Suite("Game Manager")
@MainActor
struct GameManagerTests {

    @Test func initialStateIsGameOver() {
        let manager = GameManager()
        #expect(manager.state == .gameOver)
    }

    @Test func initialScoreIsZero() {
        let manager = GameManager()
        #expect(manager.score == 0)
        #expect(manager.level == 1)
    }

    @Test func initialBoardIsEmpty() {
        let manager = GameManager()
        let allEmpty = manager.gameBoard.allSatisfy { row in
            row.allSatisfy { cell in
                cell.isFilled == false
            }
        }
        #expect(allEmpty)
    }

    @Test func initialBoardDimensions() {
        let manager = GameManager()
        #expect(manager.gameBoard.count == 20)
        #expect(manager.gameBoard.first?.count == 10)
    }

    @Test func newGameSetsPlayingState() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        #expect(manager.state == .playing)
    }

    @Test func newGameResetsScore() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        #expect(manager.score == 0)
        #expect(manager.level == 1)
    }

    @Test func newGameClearsHeldTetromino() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        #expect(manager.heldTetromino == nil)
        #expect(manager.canHoldTetromino == true)
    }

    @Test func resumeSetsPlayingState() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.resume)
        #expect(manager.state == .playing)
    }

    @Test func pauseSetsPausedState() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.resume)
        manager.handleAction(.pause)
        #expect(manager.state == .paused)
    }

    @Test func moveLeftChangesPosition() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.resume)

        let originalColumn = manager.currentTetromino.position.column
        manager.handleAction(.moveLeft)
        #expect(manager.currentTetromino.position.column == originalColumn - 1)
    }

    @Test func moveRightChangesPosition() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.resume)

        let originalColumn = manager.currentTetromino.position.column
        manager.handleAction(.moveRight)
        #expect(manager.currentTetromino.position.column == originalColumn + 1)
    }

    @Test func moveDoesNothingWhenPaused() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.pause)

        let originalColumn = manager.currentTetromino.position.column
        manager.handleAction(.moveLeft)
        #expect(manager.currentTetromino.position.column == originalColumn)
    }

    @Test func moveDoesNothingWhenGameOver() {
        let manager = GameManager()

        let originalColumn = manager.currentTetromino.position.column
        manager.handleAction(.moveLeft)
        #expect(manager.currentTetromino.position.column == originalColumn)
    }

    @Test func holdSwapsTetrominoOnFirstHold() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.resume)

        let originalCurrent = manager.currentTetromino
        manager.handleAction(.hold)

        #expect(manager.heldTetromino?.shape == originalCurrent.shape)
        #expect(manager.canHoldTetromino == false)
    }

    @Test func holdCannotBeUsedTwiceWithoutPlacing() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.resume)

        manager.handleAction(.hold)
        let afterFirstHold = manager.currentTetromino
        manager.handleAction(.hold)
        #expect(manager.currentTetromino.shape == afterFirstHold.shape)
    }

    @Test func rotateChangesTetrominoShape() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.resume)

        let originalState = manager.currentTetromino.rotationState
        manager.handleAction(.rotate)

        let hasMultipleRotations = manager.currentTetromino.rotations.count > 1
        if hasMultipleRotations {
            #expect(manager.currentTetromino.rotationState != originalState)
        }
    }

    @Test func rotateDoesNothingWhenNotPlaying() {
        let manager = GameManager()
        manager.handleAction(.newGame)
        manager.handleAction(.pause)

        let originalState = manager.currentTetromino.rotationState
        manager.handleAction(.rotate)
        #expect(manager.currentTetromino.rotationState == originalState)
    }

    @Test func nextTetrominoIsAssigned() {
        let manager = GameManager()
        #expect(manager.nextTetromino.shape.isEmpty == false)
    }

    @Test func currentTetrominoIsAssigned() {
        let manager = GameManager()
        #expect(manager.currentTetromino.shape.isEmpty == false)
    }
}
