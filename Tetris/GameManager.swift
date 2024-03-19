//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var grid: [[Block?]]
    @Published var currentTetromino: [Block]?
    @Published var heldTetromino: [Block]?
    @Published var nextTetromino: [Block]?
    @Published var gameState: GameState = .gameOver
    @Published var score: Int = 0
    
    private var timer: AnyCancellable?
    private let normalDropInterval: TimeInterval = 0.5
    private let fastDropInterval: TimeInterval = 0.05
    private var currentDropInterval: TimeInterval
    
    let rows: Int = 20
    let columns: Int = 10
    
    init() {
        self.grid = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        self.currentDropInterval = normalDropInterval
        nextTetromino = TetrominoFactory.generate()
    }
    
    func getAllBlocks() -> [Block] {
        var allBlocks = grid.flatMap { $0 }.compactMap { $0 }
        if let tetromino = currentTetromino {
            allBlocks.append(contentsOf: tetromino)
        }
        return allBlocks
    }

    func startGame() {
        resetGame()
        gameState = .playing
        spawnTetromino()
        startTimer()
    }
    
    func toggleSoftDrop(isEnabled: Bool) {
        currentDropInterval = isEnabled ? fastDropInterval : normalDropInterval
        startTimer()
    }
    
    func moveLeft() {
        guard gameState == .playing, canMoveTetromino(dx: -1, dy: 0), let tetromino = currentTetromino else { return }
        currentTetromino = tetromino.map { Block(x: $0.x - 1, y: $0.y, color: $0.color) }
    }
    
    func moveRight() {
        guard gameState == .playing, canMoveTetromino(dx: 1, dy: 0), let tetromino = currentTetromino else { return }
        currentTetromino = tetromino.map { Block(x: $0.x + 1, y: $0.y, color: $0.color) }
    }
    
    func rotateTetromino() {
        guard let currentTetromino = currentTetromino, gameState == .playing else { return }
        let pivot = currentTetromino[1]
        let rotatedBlocks = currentTetromino.map { block -> Block in
            let translatedX = block.x - pivot.x
            let translatedY = block.y - pivot.y
            let rotatedX = -translatedY
            let rotatedY = translatedX
            return Block(x: rotatedX + pivot.x, y: rotatedY + pivot.y, color: block.color)
        }
        if rotatedBlocks.allSatisfy({ canMoveTetromino(dx: $0.x - pivot.x, dy: $0.y - pivot.y) }) {
            self.currentTetromino = rotatedBlocks
        }
    }
    
    func spawnTetromino() {
        guard gameState == .playing, let tetromino = nextTetromino else { return }
        let canBePlaced = tetromino.allSatisfy { block in
            let isInVisibleGrid = block.y >= 0
            return isInVisibleGrid && isInBounds(x: block.x, y: block.y, allowSpawnAboveGrid: true) && (isInVisibleGrid ? grid[block.y][block.x] == nil : true)
        }
        if canBePlaced {
            currentTetromino = tetromino
            nextTetromino = TetrominoFactory.generate()
        } else {
            gameState = .gameOver
            stopTimer()
        }
    }
    
    func moveTetrominoDown() {
        guard gameState == .playing else { return }
        if let tetromino = currentTetromino, canMoveTetromino(dx: 0, dy: 1) {
            currentTetromino = tetromino.map { block in
                guard isInBounds(x: block.x, y: block.y + 1) else { return block }
                return Block(x: block.x, y: block.y + 1, color: block.color)
            }
            objectWillChange.send()
        } else {
            placeTetromino()
            spawnTetromino()
        }
    }
    
    func placeTetromino() {
        guard let tetromino = currentTetromino, gameState == .playing else { return }
        if tetromino.first(where: { !isInBounds(x: $0.x, y: $0.y) }) != nil {
            gameState = .gameOver
            return
        }
        tetromino.forEach { block in
            grid[block.y][block.x] = block
        }
        currentTetromino = nil
        checkForCompletedLines()
    }
    
    func canMoveTetromino(dx: Int, dy: Int) -> Bool {
        guard let tetromino = currentTetromino else { return false }
        return tetromino.allSatisfy { block in
            let newX = block.x + dx
            let newY = block.y + dy
            return isInBounds(x: newX, y: newY) && (grid[newY][newX] == nil || newY < 0)
        }
    }
    
    func checkForCompletedLines() {
        let completedLinesIndexes = grid.enumerated().compactMap { $1.allSatisfy({ $0 != nil }) ? $0 : nil }
        let linesCleared = completedLinesIndexes.count
        completedLinesIndexes.reversed().forEach { index in
            grid.remove(at: index)
            grid.insert(Array(repeating: nil, count: columns), at: 0)
        }
        updateScore(linesCleared: linesCleared)
    }
    
    func isInBounds(x: Int, y: Int, allowSpawnAboveGrid: Bool = false) -> Bool {
        let xIsValid = x >= 0 && x < columns
        let yIsValidForSpawn = allowSpawnAboveGrid ? (y >= -1 && y < rows) : (y >= 1 && y < rows)
        return xIsValid && yIsValidForSpawn
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.publish(every: currentDropInterval, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.moveTetrominoDown()
            }
        }
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func updateScore(linesCleared: Int) {
        let scores = [1: 100, 2: 300, 3: 500, 4: 800]
        score += scores[linesCleared] ?? 0
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        currentTetromino = nil
        heldTetromino = nil
        nextTetromino = TetrominoFactory.generate()
        gameState = .gameOver
        score = 0
        currentDropInterval = normalDropInterval
    }
}
