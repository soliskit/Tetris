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
    var board: [[Block?]]
    /// Track locked blocks on the game board.
    var blocks: [Block] = []
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
        // Add the blocks of the current piece to the locked blocks list.
        guard let piece = currentPiece else { return }
        let blocksToAdd = piece.generateBlocks()
        self.blocks.append(contentsOf: blocksToAdd)
        
        // Update the board representation with the new blocks.
        for block in blocksToAdd {
            guard block.y >= 0 && block.y < rows && block.x >= 0 && block.x < columns else { continue }
            board[block.y][block.x] = block
        }
        
        // Reset the current piece as it's now locked.
        currentPiece = nil
    }
    
    /// Checks each row of the board for completion (full row), clears them, and updates the score accordingly.
    private func removeCompletedLines() {
        // Identify completed lines by their indices.
        let completedLineIndices = board.indices.filter { row in
            board[row].allSatisfy { $0 != nil }
        }
        // Check if there are completed lines to clear.
        guard !completedLineIndices.isEmpty else { return }
        // Clear the completed lines and move down the remaining blocks.
        completedLineIndices.reversed().forEach { index in
            board.remove(at: index)
        }
        // Add the same number of empty lines to the top of the board.
        board.insert(contentsOf: Array(repeating: Array(repeating: nil, count: columns), count: completedLineIndices.count), at: 0)
        
        applyScoring(linesRemoved: completedLineIndices.count)
    }
    
    private func applyScoring(linesRemoved: Int) {
        let pointsPerLine = 100
        let scoreBonus = linesRemoved * pointsPerLine
        score += scoreBonus
    }
    
    /// Validates if the specified position for a piece does not collide with existing blocks or the board's boundaries.
    /// - Parameters:
    ///   - piece: The Tetris piece to check for validity.
    ///   - position: The position where the piece is attempting to move or rotate into.
    /// - Returns: `true` if the position is valid (no collisions and within boundaries); otherwise, `false`.
    private func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        // Flatten the piece shape into coordinates with their corresponding block status.
        let coordinatesWithBlocks = piece.shape
            .enumerated()
            .flatMap { y, row -> [(x: Int, y: Int, block: Bool)] in
                row.enumerated().map { x, block in (x: x + Int(position.x), y: y + Int(position.y), block: block) }
            }
            .filter { $0.block } // Consider only the blocks (true values).
        // Perform boundary and overlap checks.
        return coordinatesWithBlocks.allSatisfy { coordinate in
            let (x, y, _) = coordinate
            // Boundary check
            let isInBounds = x >= 0 && x < columns && y < rows
            // Overlap check: true if y is negative or the position on the board is empty.
            let noOverlap = y < 0 || board.indices.contains(y) && board[y].indices.contains(x) && board[y][x] == nil
            return isInBounds && noOverlap
        }
    }
    
    // MARK: - Helper Functions
    
    /// Resets the game state to initial conditions, preparing for a new game.
    private func resetGameState() {
        isGameOver = false
        isPaused = false
        isPieceHeld = false
        heldPiece = nil
        currentPiece = nil
        nextPiece = nil
        blocks.removeAll()
        score = 0
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        prepareNextPiece()
    }
}
