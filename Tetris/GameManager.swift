//
//  GameManager.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

class GameManager: ObservableObject {
    private let rows: Int = 20
    private let columns: Int = 10
    private let normalDropSpeed: TimeInterval = 1.0
    private let softDropSpeed: TimeInterval = 0.1
    @Published var currentPiece: Tetromino
    @Published var heldPiece: Tetromino?
    @Published var nextPiece: Tetromino
    @Published var tetrominos: [Tetromino] = []
    @Published var gameBoard: [[Bool]]
    @Published var gameTimer: Timer?
    @Published var state: GameState = .gameOver
    @Published var gameScore: Int = 0
    @Published var gameLevel: Int = 1
    
    init() {
        currentPiece = TetrominoFactory.generate()
        nextPiece = TetrominoFactory.generate()
        gameBoard = Array(repeating: Array(repeating: false, count: 10), count: 20)
    }
    
    func startGame() {
        spawnNewTetromino()
        gameBoard = Array(repeating: Array(repeating: false, count: 10), count: 20)
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
    
    private func spawnNewTetromino() {
        var newPiece = TetrominoFactory.generate()
        newPiece.row = 0
        newPiece.column = CGFloat(columns / 2) - CGFloat(newPiece.shape[0].count / 2)
        
        if isPiecePositionValid(newPiece) {
            tetrominos.append(newPiece)
            currentPiece = newPiece
            updateGameBoard()
        } else {
            gameOver()
        }
    }
    
    func movePieceDown(isSoftDropping: Bool = false) {
        guard state == .playing else { return }
        var movedPiece = currentPiece
        movedPiece.row += 1
        if isPiecePositionValid(movedPiece) {
            currentPiece = movedPiece
            updateGameBoard()
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
    
    private func lockPiecePosition() {
        guard state == .playing else { return }
        currentPiece.shape.enumerated().forEach { y, row in
            row.enumerated().forEach { x, cell in
                guard cell else { return }
                let globalRow = Int(currentPiece.row) + y
                let globalCol = Int(currentPiece.column) + x
                if globalRow >= 0, globalRow < rows, globalCol >= 0, globalCol < columns {
                    gameBoard[globalRow][globalCol] = true
                }
            }
        }
        tetrominos.removeAll { $0.id == currentPiece.id }
        removeCompletedLines()
    }
    
    private func removeCompletedLines() {
        let linesToClear = gameBoard.enumerated().filter { $0.element.allSatisfy { $0 } }.map { $0.offset }
        linesToClear.reversed().forEach { line in
            gameBoard.remove(at: line)
            gameBoard.insert(Array(repeating: false, count: columns), at: 0)
        }
        tetrominos = tetrominos.map { tetromino in
            var newTetromino = tetromino
            let linesBelow = linesToClear.filter { $0 < Int(tetromino.row) }.count
            if linesBelow > 0 {
                newTetromino.row += CGFloat(linesBelow)
            }
            return newTetromino
        }
        if !linesToClear.isEmpty {
            updateGameBoard()
            gameScore += calculateScore(forLines: linesToClear.count)
            gameLevel = (gameScore / 1000) + 1
        }
    }
    
    private func updateGameBoard() {
        gameBoard = Array(repeating: Array(repeating: false, count: columns), count: rows)
        tetrominos.forEach { tetromino in
            tetromino.shape.enumerated().forEach { rowIndex, row in
                row.enumerated().forEach { colIndex, isOccupied in
                    guard isOccupied else { return }
                    let globalRow = Int(tetromino.row) + rowIndex
                    let globalCol = Int(tetromino.column) + colIndex
                    if globalRow < rows && globalCol < columns && globalRow >= 0 && globalCol >= 0 {
                        gameBoard[globalRow][globalCol] = true
                    }
                }
            }
        }
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
        var movedPiece = currentPiece
        movedPiece.column -= 1
        if isPiecePositionValid(movedPiece) {
            currentPiece = movedPiece
            updateGameBoard()
        }
    }
    
    private func movePieceRight() {
        guard state == .playing else { return }
        var movedPiece = currentPiece
        movedPiece.column += 1
        if isPiecePositionValid(movedPiece) {
            currentPiece = movedPiece
            updateGameBoard()
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
        guard state == .playing else { return }
        var piece = currentPiece
        piece.rotate()
        if isPiecePositionValid(piece) {
            currentPiece = piece
            updateGameBoard()
            removeCompletedLines()
        }
    }
    
    private func applyWallKick(clockwise: Bool) -> Bool {
        // Implement wall kick. This tries to move the piece into a valid position if the initial rotation is blocked.
        // Returns true if a valid position is found, false otherwise.
        
        return false
    }
    
    private func isPiecePositionValid(_ piece: Tetromino) -> Bool {
        !piece.shape.enumerated().contains { y, row in
            row.enumerated().contains { x, cell in
                cell && {
                    let globalRow = Int(piece.row) + y
                    let globalCol = Int(piece.column) + x
                    
                    if globalRow < 0 || globalRow >= rows || globalCol < 0 || globalCol >= columns {
                        return true
                    }
                    if tetrominos.contains(where: { otherPiece in
                        otherPiece.id != piece.id && otherPiece.shape.enumerated().contains { otherY, otherRow in
                            otherRow.enumerated().contains { otherX, otherCell in
                                otherCell && (Int(otherPiece.row) + otherY, Int(otherPiece.column) + otherX) == (globalRow, globalCol)
                            }
                        }
                    }) {
                        return true
                    }
                    return gameBoard[globalRow][globalCol]
                }()
            }
        }
    }
    
    private func updateGameSpeed() {
        let interval = normalDropSpeed / Double(gameLevel)
        if gameTimer?.timeInterval != interval {
            startGameTimer()
        }
    }
    
    private func calculateScore(forLines lines: Int) -> Int {
        let scores = [1: 100, 2: 300, 3: 500, 4: 800]
        return scores[lines] ?? 0
    }
}
