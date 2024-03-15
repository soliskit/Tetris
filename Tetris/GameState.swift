//
//  GameState.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI
import Combine

/// `GameState` manages the state of a Tetris game, including the game board, current piece, game status, and score.
@Observable
class GameState {
    // MARK: - Properties
    let rows = 20
    let columns = 10
    private var gameTimer: Timer?
    /// The game board represented as a 2D array of optional `Color` values, where `nil` indicates an empty space./
    var board: [[Color?]]
    /// The current falling piece in the game.
    var currentPiece: TetrisPiece?
    var isGameOver: Bool = true
    var score: Int = 0
    
    // MARK: - Initialization
    init() {
        self.board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }
    
    // MARK: - Timer
    /// Called at regular intervals by `gameTimer`. It moves the current piece down or locks it in place and checks for game over.
    @objc private func gameTick() {
        if !movePieceDownOrLock() {
            lockPiece()
            if !spawnNewPiece() {
                gameOver()
            }
        }
    }
    
    /// Starts or restarts the game by resetting the game state and spawning a new piece.
    func startGame() {
        isGameOver = false
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        score = 0
        if !spawnNewPiece() {
            gameOver()
        } else {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gameTick), userInfo: nil, repeats: true)
        }
    }
    
    /// Ends the game and stops the game timer.
    private func gameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    // MARK: - Piece Movement
    /// Spawns a new Tetris piece at the top of the board.
    /// - Returns: A Boolean value indicating whether the new piece could be placed.
    private func spawnNewPiece() -> Bool {
        let newPiece = TetrisPieceFactory.createPiece(columns: columns)
        if isPositionValid(piece: newPiece, position: newPiece.position) {
            currentPiece = newPiece
            return true
        } else {
            return false
        }
    }
    
    /// Checks if a given piece can be placed at a specified position without causing a collision.
    /// - Parameters:
    ///   - piece: The Tetris piece to check.
    ///   - position: The position to check the piece against.
    /// - Returns: A Boolean value indicating whether the position is valid.
    private func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        for (y, row) in piece.shape.enumerated() {
            for (x, block) in row.enumerated() {
                if block {
                    let boardX = Int(position.x) + x
                    let boardY = Int(position.y) + y
                    if boardX < 0 || boardX >= columns || boardY < 0 || boardY >= rows || board[boardY][boardX] != nil {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    /// Attempts to move the current piece down by one row or locks it in place if it cannot move further.
    /// - Returns: A Boolean value indicating whether the piece was successfully moved down.
    func movePieceDownOrLock() -> Bool {
        guard var piece = currentPiece, !isGameOver else { return false }
        let newPosition = CGPoint(x: piece.position.x, y: piece.position.y + 1)
        if isPositionValid(piece: piece, position: newPosition) {
            piece.position = newPosition
            currentPiece = piece
            return true
        } else {
            lockPiece()
            removeCompletedLines()
            return false
        }
    }
    
    /// Locks the current piece into the board, making it a permanent part of the game state, and checks for completed lines.
    private func lockPiece() {
        guard let piece = currentPiece else { return }
        for (y, row) in piece.shape.enumerated() {
            for (x, block) in row.enumerated() {
                if block {
                    let boardX = Int(piece.position.x) + x
                    let boardY = Int(piece.position.y) + y
                    board[boardY][boardX] = piece.color
                }
            }
        }
        currentPiece = nil
        removeCompletedLines()
    }
    
    /// Checks for and clears any complete lines from the board, updating the score accordingly.
    private func removeCompletedLines() {
        var linesCleared = [Int]() // Holds the indices of complete lines
        
        // Check each row to see if it's complete (no nil values)
        for (index, row) in board.enumerated() {
            if row.allSatisfy({ $0 != nil }) {
                linesCleared.append(index)
            }
        }
        
        // For each cleared line, remove it from the board and add a new empty row at the top
        for lineIndex in linesCleared.reversed() {
            board.remove(at: lineIndex)
            board.insert(Array(repeating: nil, count: columns), at: 0)
        }
        
        // Update the score based on the number of lines cleared
        // Scoring could be more sophisticated based on the number of lines cleared simultaneously
        score += linesCleared.count * 100 // Example scoring: 100 points per line
        
        // If any lines were cleared, check if a new piece can be spawned or if the game is over
        if !linesCleared.isEmpty {
            if !spawnNewPiece() {
                gameOver()
            }
        }
    }
    
    // MARK: - Controls
    /// Moves the current piece one position to the left, if possible.
    func movePieceLeft() {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x - 1, y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    /// Moves the current piece one position to the right, if possible.
    func movePieceRight() {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x + 1, y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    /// Rotates the current piece to its next rotation state, if possible.
    func rotatePiece() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.rotate()
        if isPositionValid(piece: piece, position: piece.position) {
            currentPiece = piece
        }
    }
    
    /// Drops the current piece to the lowest possible position immediately.
    func dropPiece() {
        while movePieceDownOrLock() {}
    }
}
