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
    @Published var state: GameState = .paused
    @Published var gameScore: Int = 0
    @Published var gameLevel: Int = 1
    
    init() {
        currentPiece = TetrominoFactory.generate()
        nextPiece = TetrominoFactory.generate()
        gameBoard = Array(repeating: Array(repeating: nil, count: 10), count: 20)
    }
    
    func startGame() {
        currentPiece = TetrominoFactory.generate()
        nextPiece = TetrominoFactory.generate()
        gameBoard = Array(repeating: Array(repeating: nil, count: 10), count: 20)
        state = .playing
        gameScore = 0
        gameLevel = 1
        startGameTimer()
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
        // Logic to lock the Tetromino on the game board and check for completed lines
    }
    
    private func spawnNewPiece() {
        currentPiece = nextPiece
        nextPiece = TetrominoFactory.generate()
    }
    
    func handleAction(_ action: PlayerAction) {
        switch action {
            case .moveLeft:
                movePieceLeft()
            case .moveRight:
                movePieceRight()
            case .hold:
                holdPiece()
            case .softDrop:
                toggleSoftDrop()
            case .pause:
                pauseGame()
            case .start:
                startGame()
        }
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
    
    func toggleSoftDrop() {
        guard state == .playing else { return }
        if gameTimer?.timeInterval != softDropSpeed {
            startGameTimer(withSoftDrop: true)
        } else {
            startGameTimer()
        }
    }
    
    func rotateCurrentPiece(clockwise: Bool) {
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
        for y in 0..<piece.shape.count {
            for x in 0..<piece.shape[y].count {
                if piece.shape[y][x] {
                    let boardRow = Int(piece.row) + y
                    let boardColumn = Int(piece.column) + x
                    if boardRow < 0 || boardRow >= gameBoard.count || boardColumn < 0 || boardColumn >= gameBoard[0].count {
                        return false
                    }
                    
                    if gameBoard[boardRow][boardColumn] != nil {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    private func updateGameAfterRotation() {
        // Update any game state necessary after a successful rotation.
        // This could include checking for line clears or updating the display.
    }
}

