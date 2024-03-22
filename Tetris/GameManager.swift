//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

@Observable
class GameManager {
    // MARK: - Properties
    @ObservationIgnored
    @AppStorage("highScore") private var highScore: Int = 0
    private var gameControllerManager: GameControllerManager?
    private let rows: Int = 20
    private let columns: Int = 10
    private var standardDropInterval: TimeInterval = 0.6
    private let quickDropInterval: TimeInterval = 0.01
    private var timer: Timer?
    var currentTetromino: Tetromino
    var nextTetromino: Tetromino
    var heldTetromino: Tetromino?
    var canHoldTetromino: Bool = true
    var gameBoard: [[GameCell?]]
    var state: GameState = .gameOver
    var score: Int = 0
    var level: Int = 1
    
    // MARK: - Initialization & Deinitialization
    init() {
        currentTetromino = TetrominoFactory.generate()
        nextTetromino = TetrominoFactory.generate()
        gameBoard = Array(repeating: Array(repeating: GameCell(), count: columns), count: rows)
        gameControllerManager = GameControllerManager(gameManager: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Game State Management
    func startGame() {
        resetGame()
        startGameTimer()
    }
    
    private func resetGame() {
        state = .playing
        gameBoard = Array(repeating: Array(repeating: GameCell(), count: columns), count: rows)
        score = 0
        level = 1
        heldTetromino = nil
    }
    
    private func gameOver() {
        state = .gameOver
        stopGameTimer()
    }
    
    // MARK: - Tetromino Management
    private func generateNextTetromino() {
        currentTetromino = nextTetromino
        nextTetromino = TetrominoFactory.generate()
        canHoldTetromino = true
        if !isValidTetrominoPosition(tetromino: currentTetromino, at: currentTetromino.position) {
            gameOver()
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
        if isSoftDropping {
            startGameTimer(withSoftDrop: true)
        } else {
            startGameTimer()
        }
    }
    
    private func lockTetrominoInPlace() {
        currentTetromino.shape.enumerated().forEach { y, row in
            row.enumerated().forEach { x, block in
                guard block else { return }
                let boardX = Int(currentTetromino.position.column) + x
                let boardY = Int(currentTetromino.position.row) + y
                if let _ = gameBoard[safe: boardY], let _ = gameBoard[safe: boardX] {
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
        standardDropInterval = max(0.1, 1.0 * pow(0.9, Double(level)))
        if score > highScore {
            highScore = score
        }
    }
    
    private func isValidTetrominoPosition(tetromino: Tetromino, at position: Position) -> Bool {
        let newTetromino = Tetromino(shape: tetromino.shape, color: tetromino.color, position: position, rotations: tetromino.rotations, wallKickData: tetromino.wallKickData)
        return newTetromino.fitsWithin(gameBoard: gameBoard)
    }
    
    // MARK: - Timer Management
    private func startGameTimer(withSoftDrop: Bool = false) {
        let interval = withSoftDrop ? quickDropInterval : standardDropInterval / Double(level)
        stopGameTimer()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
    }
    
    private func stopGameTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func updateGame() {
        guard state != .gameOver else { return }
        dropTetromino()
    }
    
    // MARK: - Gameplay Controls
    func handleAction(_ action: PlayerAction) {
        switch action {
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
            case .pause:
                state = .paused
                stopGameTimer()
            case .resume:
                state = .playing
                startGameTimer()
        }
    }
    
    private func moveTetromino(horizontalBy deltaX: Int) {
        guard state == .playing else { return }
        let newPosition = Position(row: currentTetromino.position.row, column: currentTetromino.position.column + CGFloat(deltaX))
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
    
    private func togglePauseResume() {
        if state == .playing {
            state = .paused
            stopGameTimer()
        } else {
            state = .playing
            startGame()
        }
    }
}
