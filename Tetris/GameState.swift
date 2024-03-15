//
//  GameState.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI
import Combine

class GameState: ObservableObject {
    @Published var board: [[Color?]]
    @Published var currentPiece: TetrisPiece?
    @Published var isGameOver: Bool = true
    @Published var score: Int = 0
    private var gameTimer: Timer?
    let rows = 20
    let columns = 10
    
    init() {
        self.board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }
    
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
    
    @objc private func gameTick() {
        if !movePieceDownOrLock() {
            lockPiece()
            if !spawnNewPiece() {
                gameOver()
            }
        }
    }
    
    func movePieceLeft() {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x - 1, y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    func movePieceRight() {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x + 1, y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    func dropPiece() {
        while movePieceDownOrLock() {}
    }
    
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
    
    
    func rotatePiece() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.rotate()
        if isPositionValid(piece: piece, position: piece.position) {
            currentPiece = piece
        }
    }
    
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
    
    private func spawnNewPiece() -> Bool {
        let newPiece = TetrisPieceFactory.createPiece(columns: columns)
        if isPositionValid(piece: newPiece, position: newPiece.position) {
            currentPiece = newPiece
            return true
        } else {
            return false
        }
    }
    
    private func gameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
}
