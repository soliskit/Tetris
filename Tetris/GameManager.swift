//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

class GameManager: ObservableObject {
    private let normalDropSpeed: TimeInterval = 1.0
    private let softDropSpeed: TimeInterval = 0.1
    @Published var currentPiece: Tetromino
    @Published var heldPiece: Tetromino?
    @Published var nextPiece: Tetromino
    @Published var gameBoard: [[Tetromino?]]
    @Published var gameTimer: Timer?
    @Published var state: GameState = .gameOver
    @Published var gameScore: Int = 0
    @Published var gameLevel: Int = 1
    
    init() {
        spawnNewPiece()
        gameBoard = Array(repeating: Array(repeating: nil, count: 10), count: 20)
    }
    
    func startGame() {
        spawnNewPiece()
        gameBoard = Array(repeating: Array(repeating: nil, count: 10), count: 20)
        state = .playing
        gameScore = 0
        gameLevel = 1
        startGameTimer()
    }
    
    private func gameOver() {
        state = .gameOver
        gameTimer?.invalidate()
    }
    
    private func startGameTimer(withSoftDrop: Bool = false) {
        gameTimer?.invalidate()
        let interval = withSoftDrop ? softDropSpeed : normalDropSpeed / Double(gameLevel)
        gameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.movePieceDown(isSoftDropping: withSoftDrop)
        }
    }
    
    private func spawnNewPiece() {
        currentPiece = nextPiece
        nextPiece = TetrominoFactory.generate()
    }
    
    private func movePieceDown(isSoftDropping: Bool = false) {
        guard state == .playing else { return }
        currentPiece.row += 1
        if !isPiecePositionValid(currentPiece) {
            currentPiece.row -= 1
            lockPiecePosition()
            spawnNewPiece()
            if isSoftDropping {
                startGameTimer()
            }
        }
    }
    
    private func lockPiecePosition() {
        if isPiecePositionValid(currentPiece) {
            let shape = currentPiece.shape
            shape.enumerated().forEach { y, row in
                row.enumerated().forEach { x, isFilled in
                    guard isFilled else { return }
                    let boardRow = Int(currentPiece.row) + y
                    let boardColumn = Int(currentPiece.column) + x
                    if boardRow < gameBoard.count && boardColumn < gameBoard[0].count {
                        gameBoard[boardRow][boardColumn] = currentPiece
                    }
                }
            }
            checkCompletedLines()
        }
    }
    
    private func checkCompletedLines() {
        let linesToRemove = gameBoard.enumerated().compactMap { $0.element.allSatisfy { $0 != nil } ? $0.offset : nil }
        linesToRemove.reversed().forEach { rowIndex in
            gameBoard.remove(at: rowIndex)
            gameBoard.insert(Array(repeating: nil, count: 10), at: 0)
        }
        if linesToRemove.count > 0 {
            gameScore += calculateScore(forLines: linesToRemove.count)
        }
    }
    
    private func updateGameAfterRotation() {
        // Update any game state necessary after a successful rotation.
        // This could include checking for line clears or updating the display.
    }
    
    func handleAction(_ action: PlayerAction) {
        switch action {
            case .moveLeft:
                movePieceLeft()
            case .moveRight:
                movePieceRight()
            case .hold:
                holdPiece()
            case .rotate:
                rotateCurrentPiece()
            case .drop:
                toggleSoftDrop()
            case .pause:
                pauseGame()
            case .resume:
                resumeGame()
        }
    }
    
    private func pauseGame() {
        guard state == .playing else { return }
        state = .paused
        gameTimer?.invalidate()
    }
    
    private func resumeGame() {
        guard state == .paused else { return }
        state = .playing
        startGameTimer()
    }
    
    private func movePieceLeft() {
        guard state == .playing else { return }
        currentPiece.column -= 1
        guard isPiecePositionValid(currentPiece) else {
            currentPiece.column += 1
            return
        }
    }
    
    private func movePieceRight() {
        guard state == .playing else { return }
        currentPiece.column += 1
        guard isPiecePositionValid(currentPiece) else {
            currentPiece.column -= 1
            return
        }
    }
    
    private func holdPiece() {
        guard state == .playing, let swapPiece = heldPiece else { return }
        heldPiece = currentPiece
        currentPiece = swapPiece
    }
    
    private func toggleSoftDrop() {
        guard state == .playing else { return }
        if gameTimer?.timeInterval != softDropSpeed {
            startGameTimer(withSoftDrop: true)
        } else {
            startGameTimer()
        }
    }
    
    func rotateCurrentPiece(clockwise: Bool = true) {
        guard state == .playing else { return }
        currentPiece.rotate(clockwise: clockwise)
        
        if isPiecePositionValid(currentPiece) {
            updateGameAfterRotation()
        } else {
            if !applyWallKick(clockwise: clockwise) {
                // If wall kick fails, revert the rotation
                currentPiece.rotate(clockwise: !clockwise)
            } else {
                updateGameAfterRotation()
            }
        }
    }
    
    private func applyWallKick(clockwise: Bool) -> Bool {
        // Implement wall kick. This tries to move the piece into a valid position if the initial rotation is blocked.
        // Returns true if a valid position is found, false otherwise.
        
        return false
    }
    
    private func isPiecePositionValid(_ piece: Tetromino) -> Bool {
        return !piece.shape.enumerated().contains { y, row in
            row.enumerated().contains { x, cell in
                if cell {
                    let boardRow = Int(piece.row) + y
                    let boardColumn = Int(piece.column) + x
                    return boardRow < 0 || boardRow >= gameBoard.count || boardColumn < 0 || boardColumn >= gameBoard[0].count || gameBoard[boardRow][boardColumn] != nil
                }
                return false
            }
        }
    }
    
    private func calculateScore(forLines lines: Int) -> Int {
        let scores = [1: 100, 2: 300, 3: 500, 4: 800]
        return scores[lines] ?? 0
    }
}

