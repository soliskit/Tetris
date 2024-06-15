//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

/// Manages the overall game logic, state, and interactions for Tetris.
@Observable
class GameManager {
    // MARK: - Properties
    /// Stores the highest score achieved across sessions.
    @ObservationIgnored
    @AppStorage("highScore") private var highScore: Int = 0
    /// Tracks whether the game session was successfully saved to UserDefaults.
    @ObservationIgnored
    @AppStorage("isSessionSaved") private var isSessionSaved: Bool = false
    /// Manages input from an external game controller.
    private var gameControllerManager: GameControllerManager?
    /// The number of rows in the game board.
    private let rows: Int = 20
    /// The number of columns in the game board.
    private let columns: Int = 10
    /// Timer for managing the periodic dropping of Tetrominos.
    private var timer: Timer?
    /// The current Tetromino being controlled by the player.
    var currentTetromino: Tetromino
    /// The next Tetromino that will appear after the current one is placed.
    var nextTetromino: Tetromino
    /// The Tetromino that is being held for later use.
    var heldTetromino: Tetromino?
    /// Indicates whether the player can hold a Tetromino.
    var canHoldTetromino: Bool = true
    /// The game board, represented as a 2D array of optional `GameCell`s.
    var gameBoard: [[GameCell?]]
    /// The current state of the game (e.g., playing, paused, game over).
    var state: GameState = .gameOver
    /// The current score of the player.
    var score: Int = 0
    /// The current level of the game, affecting the drop speed.
    var level: Int = 1
    /// The interval at which Tetrominos naturally drop down the game board.
    private var standardDropInterval: TimeInterval {
        max(0.3, 0.7 - (0.00001 * Double(level - 1)))
    }
    /// Calculates a very quick drop interval for soft dropping Tetrominos.
    private var quickDropInterval: TimeInterval {
        standardDropInterval * 0.000001
    }
    
    // MARK: - Initialization & Deinitialization
    /// Initializes a new game manager instance, setting up the initial game state.
    init() {
        currentTetromino = TetrominoFactory.generate()
        nextTetromino = TetrominoFactory.generate()
        gameBoard = Array(repeating: Array(repeating: GameCell(), count: columns), count: rows)
        gameControllerManager = GameControllerManager(gameManager: self)
    }
    
    /// Cleans up any resources or observers when the game manager is deinitialized.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Game State Management
    /// Resets the game to its initial state, ready for a new game to start.
    private func resetGameSession() {
        state = .paused
        gameBoard = Array(repeating: Array(repeating: GameCell(), count: columns), count: rows)
        score = 0
        level = 1
        currentTetromino = TetrominoFactory.generate()
        nextTetromino = TetrominoFactory.generate()
        heldTetromino = nil
        canHoldTetromino = true
    }
    
    /// Attempts to load the game session from UserDefaults.
    /// - If there is saved data under the key "savedGameSession", it tries to decode this data into a `GameSession` object.
    /// - Upon successful decoding, the game's state is updated with the loaded data
    private func loadGameSession() {
        if let savedGameSessionData = UserDefaults.standard.data(forKey: "savedGameSession"),
           let session = try? JSONDecoder().decode(GameSession.self, from: savedGameSessionData) {
            state = .paused
            gameBoard = session.gameBoard
            score = session.score
            level = session.level
            currentTetromino = session.currentTetromino
            nextTetromino = session.nextTetromino
            heldTetromino = session.heldTetromino
            canHoldTetromino = session.canHoldTetromino
        }
    }
    
    /// Saves the current game session to UserDefaults.
    /// - Encodes the `GameSession` object containing the current game state into JSON data.
    /// - If encoding is successful, it saves this data under the key "savedGameSession".
    /// - Sets the `isSessionSaved` flag based on whether the save operation was successful.
    private func saveGameSession() {
        let gameSession = GameSession(gameBoard: gameBoard, score: score, level: level, currentTetromino: currentTetromino, nextTetromino: nextTetromino, heldTetromino: heldTetromino, canHoldTetromino: canHoldTetromino)
        
        if let encodedData = try? JSONEncoder().encode(gameSession) {
            UserDefaults.standard.set(encodedData, forKey: "savedGameSession")
            isSessionSaved = true
        } else {
            isSessionSaved = false
        }
    }
    
    // MARK: - Tetromino Management
    /// Generates the next Tetromino and updates the game state accordingly.
    private func generateNextTetromino() {
        currentTetromino = nextTetromino
        nextTetromino = TetrominoFactory.generate()
        canHoldTetromino = true
        if !isValidTetrominoPosition(tetromino: currentTetromino, at: currentTetromino.position) {
            state = .gameOver
            stopGameTimer()
        }
    }
    
    /// Drops the current Tetromino one row down or locks it in place if it cannot move further.
    /// - Parameter isSoftDropping: Indicates if the Tetromino is being soft dropped for faster descent.
    private func dropTetromino(isSoftDropping: Bool = false) {
        guard state == .playing else { return }
        let newPosition = Position(row: currentTetromino.position.row + 1, column: currentTetromino.position.column)
        if isValidTetrominoPosition(tetromino: currentTetromino, at: newPosition) {
            currentTetromino.position = newPosition
        } else {
            lockTetrominoInPlace()
            clearFullRows()
            generateNextTetromino()
        }
        if isSoftDropping {
            startGameTimer(withSoftDrop: true)
        } else {
            startGameTimer()
        }
    }
    
    /// Locks the current Tetromino in place on the game board.
    private func lockTetrominoInPlace() {
        currentTetromino.shape.enumerated().forEach { y, row in
            row.enumerated().forEach { x, block in
                guard block else { return }
                let boardX = currentTetromino.position.column + x
                let boardY = currentTetromino.position.row + y

                if gameBoard[safeRow: boardY, safeColumn: boardX] != nil {
                    gameBoard[boardY][boardX] = GameCell(isFilled: true, color: currentTetromino.color)
                }
            }
        }
    }
    
    // MARK: - Board Management
    /// Clears all fully filled rows from the game board and updates the game state.
    private func clearFullRows() {
        let scores = [1: 100, 2: 300, 3: 500, 4: 800]
        let completedLineIndices = gameBoard.indices.filter { row in
            gameBoard[row].allSatisfy { $0?.isFilled ?? false }
        }
        guard !completedLineIndices.isEmpty else { return }
        completedLineIndices.reversed().forEach { index in
            gameBoard.remove(at: index)
        }
        let newLines = Array(repeating: Array(repeating: GameCell(), count: columns), count: completedLineIndices.count)
        gameBoard.insert(contentsOf: newLines, at: 0)
        score += scores[completedLineIndices.count]!
        level = score / 1000 + 1
        if score > highScore {
            highScore = score
        }
        saveGameSession()
    }
    
    /// Checks if a Tetromino's position is valid within the game board.
    /// - Parameters:
    ///   - tetromino: The Tetromino to check.
    ///   - position: The position to check the Tetromino against.
    /// - Returns: `true` if the Tetromino fits within the game board at the given position, `false` otherwise.
    private func isValidTetrominoPosition(tetromino: Tetromino, at position: Position) -> Bool {
        let newTetromino = Tetromino(shape: tetromino.shape, color: tetromino.color, position: position, rotations: tetromino.rotations, wallKickData: tetromino.wallKickData)
        return newTetromino.fitsWithin(gameBoard: gameBoard)
    }
    
    // MARK: - Timer Management
    /// Starts or restarts the game timer based on the current game state and whether a soft drop is happening.
    /// - Parameter withSoftDrop: If `true`, uses the quick drop interval; otherwise, calculates interval based on the level.
    private func startGameTimer(withSoftDrop: Bool = false) {
        let interval = withSoftDrop ? quickDropInterval : standardDropInterval / Double(level)
        stopGameTimer()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
    }
    
    /// Stops the current game timer, if any.
    private func stopGameTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Called by the game timer to update the game state, typically by dropping the current Tetromino.
    @objc private func updateGame() {
        guard state != .gameOver else { return }
        dropTetromino()
    }
    
    // MARK: - Gameplay Controls
    /// Handles player actions, translating them into game actions such as moving or rotating the Tetromino.
    /// - Parameter action: The player action to handle.
    func handleAction(_ action: PlayerAction) {
        switch action {
            case .newGame:
                resetGameSession()
            case .continueGame:
                loadGameSession()
            case .pause:
                state = .paused
                stopGameTimer()
                saveGameSession()
            case .resume:
                state = .playing
                startGameTimer()
            case .moveLeft:
                moveTetromino(horizontalBy: -1)
            case .moveRight:
                moveTetromino(horizontalBy: 1)
            case .hold:
                holdTetromino()
            case .rotate:
                rotateTetromino()
            case .drop:
                dropTetromino(isSoftDropping: true)
        }
    }
    
    /// Moves the current Tetromino horizontally by a specified amount, if the game state allows.
    /// - Parameter deltaX: The horizontal movement amount.
    private func moveTetromino(horizontalBy deltaX: Int) {
        guard state == .playing else { return }
        let newPosition = Position(row: currentTetromino.position.row, column: currentTetromino.position.column + deltaX)
        if isValidTetrominoPosition(tetromino: currentTetromino, at: newPosition) {
            currentTetromino.position = newPosition
        }
    }
    
    /// Holds the current Tetromino, swapping it with a previously held Tetromino if available.
    private func holdTetromino() {
        guard state == .playing, canHoldTetromino else { return }
        let previousPosition = currentTetromino.position
        if let tetrominoToSwap = heldTetromino, isValidTetrominoPosition(tetromino: tetrominoToSwap, at: previousPosition) {
            heldTetromino = currentTetromino
            currentTetromino = tetrominoToSwap
            currentTetromino.position = previousPosition
            canHoldTetromino = false
        } else if heldTetromino == nil {
            heldTetromino = currentTetromino
            generateNextTetromino()
            canHoldTetromino = false
        }
    }
    
    /// Rotates the current Tetromino, if the game state allows.
    private func rotateTetromino() {
        guard state == .playing else { return }
        currentTetromino.rotate(gameBoard: gameBoard)
    }
}
