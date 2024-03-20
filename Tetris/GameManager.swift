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
        if y >= 0 {
            return gameBoard[y][x] == nil
        }
        return true
    }
    
    private func dropTetromino() {
        guard let tetromino = currentTetromino else { return }
        let movedTetromino: [Block] = tetromino.compactMap { block in
            let newY = block.y + 1
            if newY < rows && isPositionValid(x: block.x, y: newY) && gameBoard[newY][block.x] == nil {
                return Block(x: block.x, y: newY, color: block.color)
            } else {
                return nil
            }
        }
        if movedTetromino.count == tetromino.count {
            for block in tetromino {
                if block.y >= 0 && block.y < rows && block.x >= 0 && block.x < columns {
                    gameBoard[block.y][block.x] = nil
                }
            }
            
            for block in movedTetromino {
                if block.y < rows {
                    gameBoard[block.y][block.x] = block
                }
            }
            currentTetromino = movedTetromino
        } else {
            for block in tetromino {
                if block.y < rows {
                    gameBoard[block.y][block.x] = block
                }
            }
            spawnTetromino()
        }
    }
    
    private func spawnTetromino() {
        let potentialTetromino = TetrominoFactory.generate()
        let canSpawn = potentialTetromino.allSatisfy { block in
            isPositionValid(x: block.x, y: block.y, shouldConsiderSpawnArea: true)
        }
        if canSpawn {
            self.currentTetromino = potentialTetromino
        } else {
            self.gameState = .gameOver
        }
    }
    
    private func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: currentDropSpeed, repeats: true) { [weak self] _ in
            self?.dropTetromino()
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
                dropTetromino()
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
