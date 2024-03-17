//
//  GameState.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI
import Combine

/// Manages the state of a Tetris game, including the game board, current piece, game status, and score.
@Observable
class GameState {
    // MARK: - Properties
    /// Number of rows on the game board.
    let rows = 20
    /// Number of columns on the game board.
    let columns = 10
    /// Timer to move the current piece down at set intervals.
    private var gameTimer: Timer?
    /// The game board, where nil represents an empty space and a Color represents a filled space.
    var board: [[Color?]]
    /// The currently falling Tetris piece.
    var currentPiece: TetrisPiece?
    /// The currently held Tetris piece.
    var heldPiece: TetrisPiece?
    /// Indicates if a piece is currently held
    var isPieceHeld: Bool = false
    /// The next Tetris piece to be played.
    var nextPiece: TetrisPiece?
    /// Indicates whether the game is paused.
    var isPaused: Bool = false
    /// Indicates whether the game has ended.
    var isGameOver: Bool = true
    /// Current score of the player.
    var score: Int = 0
    
    // MARK: - Initialization
    init() {
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        prepareNextPiece()
    }
    
    // MARK: - Game Session
    
    /// Advances the game state by either moving the current piece down or locking it in place and then preparing the next piece.
    @objc private func gameTick() {
        guard !isGameOver else { return }
        if !movePieceDown() {
            lockPiece()
            removeCompletedLines()
            prepareNextPiece()
        }
    }
    
    /// Pauses and resumes the game
    func togglePauseResume() {
        isPaused.toggle()
        if isPaused {
            gameTimer?.invalidate()
        } else {
            gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gameTick), userInfo: nil, repeats: true)
        }
    }
    
    /// Starts or restarts the game by resetting the game state and starting the game timer.
    func startGame() {
        resetGameState()
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gameTick), userInfo: nil, repeats: true)
    }
    
    /// Ends the game by stopping the timer and setting the game over flag.
    private func gameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    // MARK: - Piece Management
    
    /// Prepares the current piece by using the next piece and then generates the next piece for future use. Ends the game if the current piece cannot be placed.
    private func prepareNextPiece() {
        if heldPiece == nil || !isPieceHeld {
            currentPiece = nextPiece ?? TetrisPieceFactory.createPiece(columns: columns)
        }
        nextPiece = TetrisPieceFactory.createPiece(columns: columns)
        isPieceHeld = false // Reset the held piece flag
        
        if !isPositionValid(piece: currentPiece!, position: currentPiece!.position) {
            gameOver()
        }
    }
    
    // MARK: - Piece Movement & Rotation
    /// Holds or switches the current piece with the held piece.
    func holdOrSwitchPiece() {
        // If there's already a held piece, switch it with the current piece.
        if let pieceToSwitch = heldPiece {
            heldPiece = currentPiece
            currentPiece = pieceToSwitch
            // Reset the position of the currentPiece to the top of the board.
            currentPiece?.position = CGPoint(x: columns / 2, y: 0)
            // Ensure the switched piece does not collide immediately after switching.
            if !isPositionValid(piece: currentPiece!, position: currentPiece!.position) {
                // If the new position is invalid, trigger game over or handle appropriately.
                // Here, instead of immediate game over, you might want to allow the player to adjust the piece.
            }
        } else {
            // If no piece is held, hold the current piece and prepare the next one.
            heldPiece = currentPiece
            prepareNextPiece()
        }
    }
    
    /// Attempts to move the current piece down by one row, returning true if successful.
    /// If the piece cannot move down further, it locks the piece in place.
    /// - Returns: A Boolean value indicating whether the piece was successfully moved down.
    private func movePieceDown() -> Bool {
        guard let piece = currentPiece else { return false }
        let newPosition = CGPoint(x: piece.position.x, y: piece.position.y + 1)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
            return true
        } else {
            lockPiece()
            removeCompletedLines()
            return false
        }
    }
    
    /// Moves the current piece one position to the left, if possible.
    func movePieceLeft() {
        movePiece(deltaX: -1)
    }
    
    /// Moves the current piece one position to the right, if possible.
    func movePieceRight() {
        movePiece(deltaX: 1)
    }
    
    /// Moves the current piece horizontally by the specified amount and updates its position if the move is valid.
    /// - Parameter deltaX: The number of columns to move the piece horizontally. Negative for left, positive for right.
    private func movePiece(deltaX: Int) {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x + CGFloat(deltaX), y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    /// Rotates the current piece to its next orientation, if the rotation is valid.
    func rotatePiece() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.rotate()
        if isPositionValid(piece: piece, position: piece.position) {
            currentPiece = piece
        }
    }
    
    /// Drops the current piece to the lowest possible position immediately and then forces a game tick.
    func dropPiece() {
        while movePieceDown() {}
        gameTick() // Force lock and prepare the next piece.
    }
    
    // MARK: - Board & Score Management
    
    /// Locks the current piece into its position on the board, marking it as a permanent block, and then checks for completed lines.
    private func lockPiece() {
        guard let piece = currentPiece else { return }
        for (y, row) in piece.shape.enumerated() {
            for (x, block) in row.enumerated() where block {
                let boardX = Int(piece.position.x) + x
                let boardY = Int(piece.position.y) + y
                if boardY >= 0 { // Ensure the block is within the board bounds
                    board[boardY][boardX] = piece.color
                }
            }
        }
        removeCompletedLines()
    }
    
    /// Checks each row of the board for completion (full row), clears them, and updates the score accordingly.
    private func removeCompletedLines() {
        var linesCleared = [Int]() // Holds the indices of complete lines
        
        // Iterates through each row of the board to check for completion.
        for (index, row) in board.enumerated() {
            // A row is considered complete if all its elements are non-nil.
            if row.allSatisfy({ $0 != nil }) {
                // Store the index of the completed row.
                linesCleared.append(index)
            }
        }
        
        // Proceed if there are any completed lines to clear.
        if !linesCleared.isEmpty {
            // Reverse iteration to safely modify the board array while removing lines.
            for lineIndex in linesCleared.reversed() {
                // Remove the completed line.
                board.remove(at: lineIndex)
                // Add an empty line at the top.
                board.insert(Array(repeating: nil, count: columns), at: 0)
            }
            
            // Update the score based on the number of lines cleared.
            applyScoring(linesCleared: linesCleared.count)
        }
    }
    
    /// Updates the game's score based on the number of lines cleared in a single action. Provides a higher score for clearing multiple lines simultaneously, reflecting the increased difficulty and strategy in achieving such clears.
    /// - Parameter linesCleared: The number of lines cleared at once.
    private func applyScoring(linesCleared: Int) {
        let baseScore = 100 // Defines the base score awarded for clearing a single line.
        let bonusMultiplier = 2 // Defines a multiplier for clearing multiple lines to incentivize clearing more lines at once.
        
        switch linesCleared {
            case 1:
                // Award base score for a single line clear.
                score += baseScore
            case 2:
                // Award double the base score plus a bonus for clearing two lines.
                score += baseScore * 2 * bonusMultiplier
            case 3:
                // Award triple the base score plus a bonus for clearing three lines.
                score += baseScore * 3 * bonusMultiplier
            case 4:
                // Award a special "Tetris" bonus for clearing four lines simultaneously.
                score += baseScore * 4 * bonusMultiplier * 2
            default:
                break
        }
    }
    
    /// Validates if the specified position for a piece does not collide with existing blocks or the board's boundaries.
    /// - Parameters:
    ///   - piece: The Tetris piece to check for validity.
    ///   - position: The position where the piece is attempting to move or rotate into.
    /// - Returns: `true` if the position is valid (no collisions and within boundaries); otherwise, `false`.
    private func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        for (y, row) in piece.shape.enumerated() {
            for (x, block) in row.enumerated() where block {
                let boardX = Int(position.x) + x
                let boardY = Int(position.y) + y
                
                // Boundary check
                if boardX < 0 || boardX >= columns || boardY >= rows {
                    return false
                }
                
                // Overlap check with the existing pieces on the board
                if boardY >= 0 && board[boardY][boardX] != nil {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Helper Functions
    
    /// Resets the game state to initial conditions, preparing for a new game.
    private func resetGameState() {
        isGameOver = false
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        score = 0
        heldPiece = nil // Reset the held piece
        prepareNextPiece()
    }
}
