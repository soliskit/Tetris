//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

class GameManager: ObservableObject {
    @Published var gameBoard: [[Block?]]
    @Published var currentTetromino: [Block]?
    @Published var heldTetromino: [Block]?
    @Published var nextTetromino: [Block]?
    @Published var gameState: GameState = .gameOver
    @Published var score: Int = 0
    
    private var timer: Timer?
    private let normalDropSpeed: TimeInterval = 0.5
    private let fastDropSpeed: TimeInterval = 0.05
    private var currentDropSpeed: TimeInterval = 0.5
    
    let rows: Int = 20
    let columns: Int = 10
    
    init() {
        self.gameBoard = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        spawnTetromino()
    }
    
    func getAllBlocks() -> [Block] {
        var allBlocks = gameBoard.flatMap { $0 }.compactMap { $0 }
        if let tetromino = currentTetromino {
            allBlocks.append(contentsOf: tetromino)
        }
        return allBlocks
    }
    
    private func isPositionValid(x: Int, y: Int, shouldConsiderSpawnArea: Bool = false) -> Bool {
        let xIsValid = x >= 0 && x < columns
        let yIsValidForSpawn = shouldConsiderSpawnArea ? (y >= -1 && y < rows) : (y >= 0 && y < rows)
        if !(xIsValid && yIsValidForSpawn) {
            return false
        }
        if y >= 0 && y < rows {
            return gameBoard[y][x] == nil
        }
        return true
    }
    
    private func dropAndUpdateTetrominoPosition() {
        guard let tetromino = currentTetromino else { return }
        let canMoveDown = tetromino.allSatisfy { block in
            let newY = block.y + 1
            return newY < rows && isPositionValid(x: block.x, y: newY) && gameBoard[newY][block.x] == nil
        }
        if canMoveDown {
            tetromino.forEach { block in
                if isPositionValid(x: block.x, y: block.y) {
                    gameBoard[block.y][block.x] = nil
                }
            }
            let movedTetromino = tetromino.map { Block(x: $0.x, y: $0.y + 1, color: $0.color) }
            movedTetromino.forEach { block in
                if isPositionValid(x: block.x, y: block.y) {
                    gameBoard[block.y][block.x] = block
                }
            }
            currentTetromino = movedTetromino
        } else {
            tetromino.forEach { block in
                if isPositionValid(x: block.x, y: block.y) {
                    gameBoard[block.y][block.x] = block
                }
            }
            spawnTetromino()
        }
    }
    
    private func spawnTetromino() {
        guard gameState == .playing else { return }
        if let next = nextTetromino {
            self.currentTetromino = next
            self.nextTetromino = nil
        } else {
            let potentialTetromino = TetrominoFactory.generate()
            let canSpawn = potentialTetromino.allSatisfy { block in
                isPositionValid(x: block.x, y: block.y, shouldConsiderSpawnArea: true) &&
                (block.y < 0 || gameBoard[block.y][block.x] == nil)
            }
            if canSpawn {
                self.currentTetromino = potentialTetromino
            } else {
                self.gameState = .gameOver
                return
            }
        }
        let newNextTetromino = TetrominoFactory.generate()
        let canPlaceNext = newNextTetromino.allSatisfy { block in
            isPositionValid(x: block.x, y: block.y, shouldConsiderSpawnArea: true)
        }
        if canPlaceNext {
            self.nextTetromino = newNextTetromino
        } else {
            fatalError("Error: Next tetromino cannot be placed. Check game logic.")
        }
    }
    
    private func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: currentDropSpeed, repeats: true) { [weak self] _ in
            self?.dropAndUpdateTetrominoPosition()
        }
    }
    
    private func stopGameTimer() {
        timer?.invalidate()
    }
    
    func startGame() {
        gameState = .playing
        spawnTetromino()
        startGameTimer()
    }
    
    func handlePlayerAction(action: PlayerAction) {
        switch action {
            case .moveLeft:
                moveTetrominoLeft()
            case .moveRight:
                moveTetrominoRight()
            case .rotate:
                rotateTetromino()
            case .drop:
                dropAndUpdateTetrominoPosition()
            case .hold:
                holdTetromino()
        }
    }
    
    func togglePauseResumeGame() {
        if gameState == .paused {
            gameState = .playing
            startGameTimer()
        } else if gameState == .playing {
            gameState = .paused
            stopGameTimer()
        }
    }
    
    private func moveTetrominoLeft() {
        // Placeholder for left movement logic
    }
    
    private func moveTetrominoRight() {
        // Placeholder for right movement logic
    }
    
    private func rotateTetromino() {
        // Placeholder for rotation logic
    }
    
    private func holdTetromino() {
        // Swap currentTetromino with heldTetromino
    }
}

/*

 import SwiftUI
struct Block: Identifiable {
    let id = UUID()
    var x: Int
    var y: Int
    var color: Color
}
enum PlayerAction {
    case moveLeft
    case moveRight
    case rotate
    case drop
    case hold
}
enum GameState: String {
    case playing
    case paused
    case gameOver
}

class GameManager: ObservableObject {
    @Published var gameBoard: [[Block?]]
    @Published var currentTetromino: [Block]?
    @Published var heldTetromino: [Block]?
    @Published var nextTetromino: [Block]?
    @Published var gameState: GameState = .gameOver
    @Published var score: Int = 0
    
    private var timer: Timer?
    private let normalDropSpeed: TimeInterval = 0.5
    private let fastDropSpeed: TimeInterval = 0.05
    private var currentDropSpeed: TimeInterval
    
    let rows: Int = 20
    let columns: Int = 10
}
use these data models to create a game manager class for a Tetris game. Implement logic to handle spawning and dropping down a piece. Add the ability to pause and resume the game. Use player action for soft drop, moving left right and holding a piece.

*/
