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
    
    func testGameInitialization() {
        XCTAssertEqual(gameManager.rows, 20)
        XCTAssertEqual(gameManager.columns, 10)
        XCTAssertNotNil(gameManager.nextPiece)
        XCTAssertNotNil(gameManager.currentPiece)
        XCTAssertEqual(gameManager.gameBoard.count, gameManager.rows)
        XCTAssertEqual(gameManager.gameBoard.first?.count, gameManager.columns)
        XCTAssertEqual(gameManager.state, .gameOver)
    }
    
    func testGameOver() {
        gameManager.gameOver()
        XCTAssertEqual(gameManager.state, .gameOver)
    }
    
    func testStartGameTimer() {
        gameManager.startGameTimer()
        XCTAssertNotNil(gameManager.gameTimer)
        XCTAssertTrue(gameManager.gameTimer!.isValid)
    }
    
    func testStartGameTimerWithSoftDrop() {
        gameManager.startGameTimer(withSoftDrop: true)
        XCTAssertEqual(gameManager.gameTimer?.timeInterval, gameManager.softDropSpeed)
    }
    
    func testGameBoardUpdatesWithKnownTetromino() {
        gameManager.startGame()
        let testTetromino = Tetromino(shape: [[true, true, true, true]], color: .blue, position: Position(row: 0, column: 3), rotationState: 0, rotationPoints: [], wallKickData: [])
        gameManager.currentPiece = testTetromino
        
        gameManager.updateGameBoardWithCurrentPiece()
        
        let expectedPositions = testTetromino.shape.enumerated().flatMap { (y, row) -> [(Int, Int)] in
            row.enumerated().compactMap { x, isPartOfTetromino in
                isPartOfTetromino ? (Int(testTetromino.position.row) + y, Int(testTetromino.position.column) + x) : nil
            }
        }
        
        // Verify that each expected position on the gameBoard is filled and matches the tetromino's color.
        for (row, col) in expectedPositions {
            let cell = gameManager.gameBoard[row][col]
            XCTAssertTrue(cell.isFilled, "The cell at row \(row), column \(col) should be filled.")
            XCTAssertEqual(cell.color, testTetromino.color, "The cell at row \(row), column \(col) should have the correct color.")
        }
    }
    
    func testMovePieceDown() {
        gameManager.startGame()
        guard let initialRow = gameManager.currentPiece?.position.row else {
            XCTFail("Current piece should be set after starting the game and spawning a new Tetromino")
            return
        }
        gameManager.movePieceDown()
        guard let newRow = gameManager.currentPiece?.position.row else {
            XCTFail("Current piece should still be set after moving down")
            return
        }
        XCTAssertEqual(newRow, initialRow + 1, "After moving down, the Tetromino's row should increase by 1")
    }
    
//    func testMovePieceLeftRight() {
//        gameManager.startGame()
//        guard let initialColumn = gameManager.currentPiece?.position.column else {
//            XCTFail("Initial current piece should be set")
//            return
//        }
//        
//        gameManager.handleAction(.moveLeft)
//        guard let afterLeftColumn = gameManager.currentPiece?.position.column else {
//            XCTFail("Current piece should exist after moving left")
//            return
//        }
//        XCTAssertEqual(afterLeftColumn, initialColumn - 1, "Piece should move left by 1 column")
//        
//        gameManager.handleAction(.moveRight)
//        
//        guard let afterRightColumn = gameManager.currentPiece?.position.column else {
//            XCTFail("Current piece should exist after moving right")
//            return
//        }
//        XCTAssertEqual(afterRightColumn, initialColumn, "Piece should move back to initial position after moving right")
//    }
    
    func testPauseAndResumeGame() {
        gameManager.startGame()
        gameManager.handleAction(.pause)
        XCTAssertNil(gameManager.gameTimer)
        XCTAssertEqual(gameManager.state, .paused)
        
        gameManager.handleAction(.resume)
        XCTAssertEqual(gameManager.state, .playing)
        XCTAssertNotNil(gameManager.gameTimer)
    }
    
    func testTetrisPieceVisibilityWhileFalling() {
        gameManager.startGame()

         gameManager.currentPiece = Tetromino(shape: [[true, true, true, true]], color: .blue, position: Position(row: 0, column: 3), rotationState: 0, rotationPoints: [], wallKickData: [])
        
        guard let initialPiece = gameManager.currentPiece else {
            XCTFail("A Tetromino should be active after starting the game.")
            return
        }
        let initialPositions = expectedPositions(for: initialPiece)
        
        for position in initialPositions {
            let row = Int(position.row)
            let column = Int(position.column)
            
            guard row >= 0, row < gameManager.rows, column >= 0, column < gameManager.columns else {
                XCTFail("Position (\(position.row), \(position.column)) is out of bounds.")
                continue
            }
            
            let cell = gameManager.gameBoard[row][column]
            XCTAssertTrue(cell.isFilled, "Cell at (\(row), \(column)) should be filled by the initial Tetromino.")
            XCTAssertEqual(cell.color, initialPiece.color, "Cell color at (\(row), \(column)) should match the Tetromino's color.")
        }
        
        gameManager.movePieceDown()
        
        let movedPositions = expectedPositions(for: gameManager.currentPiece!)
        
        for position in movedPositions {
            let row = Int(position.row)
            let column = Int(position.column)
            
            guard row >= 0, row < gameManager.rows, column >= 0, column < gameManager.columns else {
                XCTFail("Position (\(position.row), \(position.column)) is out of bounds.")
                continue
            }
            
            let cell = gameManager.gameBoard[row][column]
            XCTAssertTrue(cell.isFilled, "Cell at (\(row), \(column)) should be filled after moving the Tetromino down.")
            // If comparing UIColors or similar, ensure they're comparable or convert them to a comparable format.
            XCTAssertEqual(cell.color, gameManager.currentPiece?.color, "Cell color at (\(row), \(column)) should match the Tetromino's color after moving down.")
        }
    }
    
    private func expectedPositions(for tetromino: Tetromino) -> [Position] {
        tetromino.shape.enumerated().flatMap { (y, row) -> [Position] in
            row.enumerated().compactMap { x, isFilled in
                isFilled ? Position(row: CGFloat(y) + tetromino.position.row, column: CGFloat(x) + tetromino.position.column) : nil
            }
        }
    }

}

