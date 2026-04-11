//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

@MainActor
@Observable
class GameManager {
    // MARK: - Properties
    @ObservationIgnored
    @AppStorage("highScore") private var highScore: Int = 0
    @ObservationIgnored
    @AppStorage("isSessionSaved") private var isSessionSaved: Bool = false
    private var gameControllerManager: GameControllerManager?
    private let rows: Int = 20
    private let columns: Int = 10
    private var gameLoopTask: Task<Void, Never>?
    var currentTetromino: Tetromino
    var nextTetromino: Tetromino
    var heldTetromino: Tetromino?
    var canHoldTetromino: Bool = true
    var gameBoard: [[GameCell?]]
    var state: GameState = .gameOver
    var score: Int = 0
    var level: Int = 1
    private var standardDropInterval: TimeInterval {
        max(0.3, 0.7 - (0.00001 * Double(level - 1)))
    }
    private var quickDropInterval: TimeInterval {
        standardDropInterval * 0.000001
    }

    // MARK: - Initialization
    init() {
        currentTetromino = TetrominoFactory.generate()
        nextTetromino = TetrominoFactory.generate()
        gameBoard = Array(repeating: Array(repeating: GameCell(), count: columns), count: rows)
        gameControllerManager = GameControllerManager(gameManager: self)
    }

    // MARK: - Game State Management
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
    private func generateNextTetromino() {
        currentTetromino = nextTetromino
        nextTetromino = TetrominoFactory.generate()
        canHoldTetromino = true
        if !isValidTetrominoPosition(tetromino: currentTetromino, at: currentTetromino.position) {
            state = .gameOver
            stopGameLoop()
        }
    }

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
        startGameLoop(withSoftDrop: isSoftDropping)
    }

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

    private func isValidTetrominoPosition(tetromino: Tetromino, at position: Position) -> Bool {
        let newTetromino = Tetromino(shape: tetromino.shape, color: tetromino.color, position: position, rotations: tetromino.rotations, wallKickData: tetromino.wallKickData)
        return newTetromino.fitsWithin(gameBoard: gameBoard)
    }

    // MARK: - Game Loop (Swift Concurrency)
    private func startGameLoop(withSoftDrop: Bool = false) {
        stopGameLoop()
        let interval = withSoftDrop ? quickDropInterval : standardDropInterval / Double(level)
        gameLoopTask = Task {
            try? await Task.sleep(for: .seconds(interval))
            guard !Task.isCancelled, state == .playing else { return }
            dropTetromino()
        }
    }

    private func stopGameLoop() {
        gameLoopTask?.cancel()
        gameLoopTask = nil
    }

    // MARK: - Gameplay Controls
    func handleAction(_ action: PlayerAction) {
        switch action {
            case .newGame:
                resetGameSession()
            case .continueGame:
                loadGameSession()
            case .pause:
                state = .paused
                stopGameLoop()
                saveGameSession()
            case .resume:
                state = .playing
                startGameLoop()
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

    private func moveTetromino(horizontalBy deltaX: Int) {
        guard state == .playing else { return }
        let newPosition = Position(row: currentTetromino.position.row, column: currentTetromino.position.column + deltaX)
        if isValidTetrominoPosition(tetromino: currentTetromino, at: newPosition) {
            currentTetromino.position = newPosition
        }
    }

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

    private func rotateTetromino() {
        guard state == .playing else { return }
        currentTetromino.rotate(gameBoard: gameBoard)
    }
}
