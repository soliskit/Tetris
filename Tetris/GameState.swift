//
//  GameState.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import Observation
import Foundation

@Observable
class GameState {
    // MARK: - Properties
    let rows = 20
    let columns = 10
    let dropDelay: TimeInterval = 0.5
    private var gameTimer: Timer?
    private var lastUpdateTime: TimeInterval?
    private var timeSinceLastDrop: TimeInterval = 0
    var board: [[Block?]]
    private(set) var blocks: [Block] = []
    private(set) var currentPiece: TetrisPiece?
    private(set) var shadowPiece: TetrisPiece?
    private(set) var heldPiece: TetrisPiece?
    private(set) var nextPiece: TetrisPiece?
    private(set) var isPieceHeld: Bool = false
    var isPaused: Bool = false
    private(set) var isGameOver: Bool = true
    private(set) var score: Int = 0
    
    var isCurrentPositionValid: Bool {
        if let currentPiece = currentPiece {
            return isPositionValid(piece: currentPiece, position: currentPiece.position)
        }
        return false
    }
    
    // MARK: - Initialization
    init() {
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        prepareNextPiece()
    }
    
    // MARK: - Game Session
    
    func togglePauseResume() {
        isPaused.toggle()
        if isPaused {
            gameTimer?.invalidate()
        } else {
            setupGameTimer()
        }
    }
    
    func startGame() {
        resetGameState()
        setupGameTimer()
    }
    
    private func gameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    @objc private func gameTick() {
        if timeSinceLastDrop >= dropDelay {
            timeSinceLastDrop = 0
            processPieceMovement()
        } else {
            let currentTime = Date().timeIntervalSinceReferenceDate
            timeSinceLastDrop += currentTime - (lastUpdateTime ?? currentTime)
        }
        lastUpdateTime = Date().timeIntervalSinceReferenceDate
    }
    
    private func processPieceMovement() {
        if !movePieceDown() {
            lockPiece()
            removeCompletedLines()
            prepareNextPiece()
        }
    }
    
    private func updateGameState() {
        if lastUpdateTime == nil {
            lastUpdateTime = Date().timeIntervalSinceReferenceDate
        }
        let currentTime = Date().timeIntervalSinceReferenceDate
        timeSinceLastDrop += currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime
        
        if timeSinceLastDrop >= dropDelay {
            timeSinceLastDrop -= dropDelay
            if let piece = currentPiece, !movePieceDown() && shouldLockPiece(piece) {
                lockPiece()
                removeCompletedLines()
                prepareNextPiece()
            }
            updateBoard()
        }
        updateShadowPiece()
    }
    
    private func attemptMoveDownOrLockPiece() {
        guard let currentPiece = currentPiece, !movePieceDown() else { return }
        if shouldLockPiece(currentPiece) {
            lockPiece()
            removeCompletedLines()
            prepareNextPiece()
        }
    }
    
    func setupGameTimer() {
        lastUpdateTime = Date().timeIntervalSinceReferenceDate
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.gameTick()
        }
    }
    
    // MARK: - Piece Movement
    
    func holdOrSwitchPiece() {
        if let pieceToSwitch = heldPiece {
            heldPiece = currentPiece
            currentPiece = pieceToSwitch
            currentPiece?.position = CGPoint(x: columns / 2, y: 0)
            if !isPositionValid(piece: currentPiece!, position: currentPiece!.position) {
                
            }
        } else {
            heldPiece = currentPiece
            prepareNextPiece()
        }
    }
    
    func movePieceLeft() {
        movePiece(deltaX: -1)
        updateBoard()
    }
    
    func movePieceRight() {
        movePiece(deltaX: 1)
        updateBoard()
    }
    
    func rotatePiece() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.rotate()
        if isPositionValid(piece: piece, position: piece.position) {
            currentPiece = piece
            updateBoard()
        }
    }
    
    func dropPiece() {
        while movePieceDown() {}
        lockPiece()
        removeCompletedLines()
        prepareNextPiece()
        updateBoard()
        timeSinceLastDrop = 0
    }
    
    // MARK: - Piece Management
        
    func prepareNextPiece() {
        currentPiece = nextPiece ?? TetrisPieceFactory.createPiece(columns: columns)
        nextPiece = TetrisPieceFactory.createPiece(columns: columns)
        if !isPositionValid(piece: currentPiece!, position: currentPiece!.position) {
            triggerGameOver()
        }
    }
    
    func movePieceDown() -> Bool {
        guard let currentPiece = currentPiece else { return false }
        let newPosition = CGPoint(x: currentPiece.position.x, y: currentPiece.position.y + 1)
        if isPositionValid(piece: currentPiece, position: newPosition) {
            self.currentPiece?.position = newPosition
            updateBoard()
            return true
        }
        return handleLockAndNewPiece()
    }
    
    func shouldLockPiece(_ piece: TetrisPiece) -> Bool {
        let newBlocks = piece.transformedBlocks(position: CGPoint(x: piece.position.x, y: piece.position.y + 1))
        return newBlocks.contains { $0.y >= rows || isBlockOccupied($0) }
    }
    
    func isBlockOccupied(_ block: Block) -> Bool {
        guard block.y < rows, block.x < columns else { return true }
        return board[block.y][block.x] != nil
    }
    
    func lockPiece() {
        guard let piece = currentPiece else { return }
        blocks += piece.generateBlocks()
        currentPiece = nil
        updateBoard()
    }
    
    func isBlockOverlapping(block: Block) -> Bool {
        let newPos = CGPoint(x: block.x, y: block.y + 1)
        return blocks.contains(where: { $0.x == Int(newPos.x) && $0.y == Int(newPos.y) })
    }
    
    // MARK: - Board & Score Management
    
    func updateBoard() {
        clearBoard()
        blocks.forEach { block in
            if withinBounds(block: block) {
                board[block.y][block.x] = block
            }
        }
        currentPiece?.generateBlocks().forEach { block in
            if withinBounds(block: block) {
                board[block.y][block.x] = block
            }
        }
    }
    
    func removeCompletedLines() {
        let completedLines = (0..<rows).filter { row in
            board[row].allSatisfy { $0 != nil }
        }
        completedLines
            .reversed()
            .forEach { index in
                board.remove(at: index)
                board.insert(Array(repeating: nil, count: columns), at: 0)
            }
        applyScoring(linesRemoved: completedLines.count)
        updateBoard()
    }
    
    private func applyScoring(linesRemoved: Int) {
        let pointsPerLine = 100
        let scoreBonus = linesRemoved * pointsPerLine
        score += scoreBonus
    }
    
     func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        piece.generateBlocks().allSatisfy { block in
            withinBounds(block: block) && (board[block.y][block.x] == nil || blocks.contains(where: { $0.id == block.id }))
        }
    }
    
    // MARK: - Helper Methods
    
    private func clearBoard() {
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }
    
    private func triggerGameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    func resetGameState() {
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
        blocks.removeAll()
        score = 0
        isGameOver = false
        isPaused = false
        prepareNextPiece()
    }
    
    private func withinBounds(block: Block) -> Bool {
        block.x >= 0 && block.x < columns && block.y < rows
    }
    
    private func movePiece(deltaX: Int) {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x + CGFloat(deltaX), y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    private func handleLockAndNewPiece() -> Bool {
        if isCurrentPositionValid {
            return false
        }
        lockPiece()
        prepareNextPiece()
        return false
    }
    
    private func updateShadowPiece() {
        guard let currentPiece = currentPiece else {
            shadowPiece = nil
            return
        }
        var projectedPiece = currentPiece
        while isPositionValid(piece: projectedPiece, position: CGPoint(x: projectedPiece.position.x, y: projectedPiece.position.y + 1)) {
            projectedPiece.position.y += 1
        }
        shadowPiece = projectedPiece
    }
}
