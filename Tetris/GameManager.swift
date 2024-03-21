//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

class GameManager: ObservableObject {
     let rows: Int = 20
     let columns: Int = 10
     let normalDropSpeed: TimeInterval = 1.0
     let softDropSpeed: TimeInterval = 0.1
    @Published var previousPosition: Position?
    @Published var currentPiece: Tetromino?
    @Published var heldPiece: Tetromino?
    @Published var nextPiece: Tetromino
    @Published var gameBoard: [[GameCell]]
    @Published var gameTimer: Timer?
    @Published var state: GameState = .gameOver
    @Published var gameScore: Int = 0
    @Published var gameLevel: Int = 1
    
    init() {
        currentPiece = TetrominoFactory.generate()
        nextPiece = TetrominoFactory.generate()
        gameBoard = Array(repeating: Array(repeating: GameCell(), count: columns), count: rows)
    }
    
    func startGame() {
        spawnNewTetromino()
        gameBoard = Array(repeating: Array(repeating: GameCell(), count: columns), count: rows)
        state = .playing
        gameScore = 0
        gameLevel = 1
        startGameTimer()
    }
    
    func gameOver() {
        state = .gameOver
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    func startGameTimer(withSoftDrop: Bool = false) {
        gameTimer?.invalidate()
        gameTimer = nil
        let interval = withSoftDrop ? softDropSpeed : normalDropSpeed / Double(gameLevel)
        gameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.movePieceDown(isSoftDropping: withSoftDrop)
        }
    }
    
    func spawnNewTetromino() {
        var newPiece = TetrominoFactory.generate()
        newPiece.position = Position(row: 0, column: CGFloat(columns / 2) - CGFloat(newPiece.shape[0].count / 2))
        if isPiecePositionValid(newPiece) {
            currentPiece = newPiece
            updateGameBoardWithCurrentPiece()
        } else {
            gameOver()
        }
    }
    
    func movePieceDown(isSoftDropping: Bool = false) {
        guard state == .playing, var movedPiece = currentPiece else { return }
        movedPiece.position.row += 1
        if isPiecePositionValid(movedPiece) {
            currentPiece = movedPiece
            updateGameBoardWithCurrentPiece()
        } else {
            lockPiecePosition()
            removeCompletedLines()
            spawnNewTetromino()
        }
        if isSoftDropping {
            startGameTimer(withSoftDrop: true)
        } else {
            startGameTimer()
        }
    }
    
    func lockPiecePosition() {
        guard state == .playing, let lockedPiece = currentPiece else { return }
        lockedPiece.shape.enumerated().forEach { y, row in
            row.enumerated().forEach { x, cell in
                guard cell else { return }
                let globalRow = Int(lockedPiece.position.row) + y
                let globalCol = Int(lockedPiece.position.column) + x
                if globalRow >= 0, globalRow < rows, globalCol >= 0, globalCol < columns {
                    gameBoard[globalRow][globalCol].isFilled = true
                    gameBoard[globalRow][globalCol].color = lockedPiece.color
                }
            }
        }
        currentPiece = nil
        previousPosition = nil
    }
    
    func removeCompletedLines() {
        let linesToClear = gameBoard.enumerated().filter { $0.element.allSatisfy { $0.isFilled } }.map { $0.offset }
        linesToClear.reversed().forEach { line in
            gameBoard.remove(at: line)
            gameBoard.insert(Array(repeating: GameCell(), count: columns), at: 0)
        }
        if !linesToClear.isEmpty {
            updateGameBoardWithCurrentPiece()
            gameScore += calculateScore(forLines: linesToClear.count)
            gameLevel = (gameScore / 1000) + 1
        }
    }
    
    func updateGameBoardWithCurrentPiece() {
        guard let currentPiece = currentPiece else { return }
        if let previousPosition = previousPosition {
            currentPiece.shape.enumerated().forEach { y, row in
                row.enumerated().forEach { x, cell in
                    if cell {
                        let globalRow = Int(previousPosition.row) + y
                        let globalCol = Int(previousPosition.column) + x
                        if globalRow >= 0, globalRow < rows, globalCol >= 0, globalCol < columns {
                            gameBoard[globalRow][globalCol].isFilled = false
                            gameBoard[globalRow][globalCol].color = nil
                        }
                    }
                }
            }
        }
        currentPiece.shape.enumerated().forEach { y, row in
            row.enumerated().forEach { x, cell in
                if cell {
                    let globalRow = Int(currentPiece.position.row) + y
                    let globalCol = Int(currentPiece.position.column) + x
                    if globalRow >= 0, globalRow < rows, globalCol >= 0, globalCol < columns {
                        gameBoard[globalRow][globalCol].isFilled = true
                        gameBoard[globalRow][globalCol].color = currentPiece.color
                    }
                }
            }
        }
        previousPosition = currentPiece.position
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
                rotatePiece()
            case .drop:
                dropPiece()
            case .pause:
                pauseGame()
            case .resume:
                resumeGame()
        }
    }
    
    private func pauseGame() {
        guard state == .playing else { return }
        gameTimer?.invalidate()
        gameTimer = nil
        state = .paused
    }
    
    private func resumeGame() {
        guard state == .paused else { return }
        startGameTimer()
        state = .playing
    }
    
    private func movePieceLeft() {
        guard state == .playing, var movedPiece = currentPiece else { return }
        previousPosition = movedPiece.position
        movedPiece.position.column -= 1
        if isPiecePositionValid(movedPiece) {
            currentPiece = movedPiece
            updateGameBoardWithCurrentPiece()
        } else {
            currentPiece?.position = previousPosition ?? Position(row: 0, column: 0)
        }
    }
    
    private func movePieceRight() {
        guard state == .playing, var movedPiece = currentPiece else { return }
        movedPiece.position.column += 1
        if isPiecePositionValid(movedPiece) {
            currentPiece = movedPiece
            updateGameBoardWithCurrentPiece()
        } else {
            currentPiece?.position = previousPosition ?? Position(row: 0, column: 0)
        }
    }
    
    private func holdPiece() {
        guard state == .playing, let swapPiece = heldPiece else { return }
        heldPiece = currentPiece
        currentPiece = swapPiece
    }
    
    private func dropPiece() {
        guard state == .playing else { return }
        if gameTimer?.timeInterval != softDropSpeed {
            startGameTimer(withSoftDrop: true)
        } else {
            startGameTimer()
        }
    }
    
    func rotatePiece() {
        guard state == .playing, var piece = currentPiece else { return }
        let originalPiece = piece
        piece.rotate(gameBoard: gameBoard)
        if isPiecePositionValid(piece) {
            currentPiece = piece
            updateGameBoardWithCurrentPiece()
        } else {
            currentPiece = originalPiece
        }
    }
    
    func isPiecePositionValid(_ tetromino: Tetromino) -> Bool {
        !tetromino.shape.enumerated().contains { y, row in
            row.enumerated().contains { x, isPartOfTetromino in
                if isPartOfTetromino {
                    let globalRow = Int(tetromino.position.row) + y
                    let globalCol = Int(tetromino.position.column) + x
                    return globalRow < 0 || globalRow >= rows || globalCol < 0 || globalCol >= columns || gameBoard[globalRow][globalCol].isFilled
                } else {
                    return false
                }
            }
        }
    }
    
     func updateGameSpeed() {
        let interval = normalDropSpeed / Double(gameLevel)
        if gameTimer?.timeInterval != interval {
            startGameTimer()
        }
    }
    
     func calculateScore(forLines lines: Int) -> Int {
        let scores = [1: 100, 2: 300, 3: 500, 4: 800]
        return scores[lines] ?? 0
    }
}
