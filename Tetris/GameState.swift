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
    
    func startGame() {
        assert(isGameOver, "startGame called but game is not in a 'game over' state.")
        resetGameState()
        setupGameTimer()
    }
    
    private func endGame() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    func togglePauseResume() {
        assert(!isGameOver, "togglePauseResume called during 'game over' state.")
        isPaused.toggle()
        if isPaused {
            gameTimer?.invalidate()
        } else {
            setupGameTimer()
        }
    }
    
    @objc private func processTime() {
        assert(Thread.isMainThread, "gameTick must be executed on the main thread.")
        guard !isGameOver && !isPaused else { return }
        
        let currentTime = Date().timeIntervalSinceReferenceDate
        if let lastTime = lastUpdateTime {
            timeSinceLastDrop += currentTime - lastTime
        }
        lastUpdateTime = currentTime
        
        if timeSinceLastDrop >= dropDelay {
            timeSinceLastDrop -= dropDelay
            processPieceMovement()
        }
    }
    
    private func processPieceMovement() {
        guard let currentPiece = self.currentPiece else { return }
        if !movePieceDown() {
            if canLockPiece(currentPiece) {
                lockPiece()
                removeCompletedLines()
                prepareNextPiece()
            } else {
                endGame()
            }
        }
        updateBoard()
    }
    
    private func setupGameTimer() {
        assert(Thread.isMainThread, "setupGameTimer must be called from the main thread.")
        lastUpdateTime = Date().timeIntervalSinceReferenceDate
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.processTime()
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
        updateBoard()
        lockPiece()
        removeCompletedLines()
        prepareNextPiece()
    }
    
    // MARK: - Piece Management
        
    func prepareNextPiece() {
        currentPiece = nextPiece ?? TetrisPieceFactory.createPiece(columns: columns)
        nextPiece = TetrisPieceFactory.createPiece(columns: columns)
        if let currentPiece = currentPiece, !isPositionValid(piece: currentPiece, position: currentPiece.position) {
            triggerGameOver()
        } else {
            updateBoard()
        }
    }
    
    func movePieceDown() -> Bool {
        guard let currentPiece = currentPiece else { return false }
        let newPosition = CGPoint(x: currentPiece.position.x, y: currentPiece.position.y + 1)
        if isPositionValid(piece: currentPiece, position: newPosition) {
            self.currentPiece?.position = newPosition
            updateBoard()
            return true
        } else {
            let blocksDirectlyBelow = currentPiece.generateBlocks().map {
                Block(x: $0.x, y: $0.y + 1, color: $0.color, parentPieceID: $0.parentPieceID)
            }
            
            let shouldLock = blocksDirectlyBelow.contains { block in
                block.y >= rows || isBlockOccupied(block)
            }
            
            if shouldLock {
                lockPiece()
            }
            
            return false
        }
    }
    
    private func lockPiece() {
        guard let piece = currentPiece else { return }
        for block in piece.generateBlocks() {
            guard withinBounds(block: block) else { continue }
            board[block.y][block.x] = block
            blocks.append(block)
        }
        if board.flatMap({ $0 }).contains(where: { $0 != nil && $0!.y == 0 }) {
            triggerGameOver()
            return
        }
        currentPiece = nil
        removeCompletedLines()
        prepareNextPiece()
        updateBoard()
        updateShadowPiece()
    }
    
    private func canLockPiece(_ piece: TetrisPiece) -> Bool {
        for block in piece.generateBlocks() {
            let newPos = CGPoint(x: block.x, y: block.y + 1)
            let newPosIntY = Int(newPos.y)
            if newPosIntY >= rows {
                return true
            }
            if newPosIntY < rows && board[newPosIntY][block.x] != nil {
                return true
            }
        }
        return false
    }
  
    func isBlockOccupied(_ block: Block) -> Bool {
        guard block.y >= 0, block.y < rows, block.x >= 0, block.x < columns else { return true }
        return board[block.y][block.x] != nil
    }
    
    func isBlockOverlapping(block: Block) -> Bool {
        let newPos = CGPoint(x: block.x, y: block.y + 1)
        return blocks.contains(where: { $0.x == Int(newPos.x) && $0.y == Int(newPos.y) })
    }
    
    // MARK: - Board & Score Management
    
    func updateBoard() {
        guard !isGameOver else { return }
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
        updateShadowPiece()
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
        guard isGameOver, !isPaused else { return }
        clearBoard()
        blocks.removeAll()
        score = 0
        isGameOver = false
        isPaused = false
        isPieceHeld = false
        heldPiece = nil
        currentPiece = nil
        nextPiece = nil
        timeSinceLastDrop = 0
        lastUpdateTime = nil
        prepareNextPiece()
    }
    
    private func withinBounds(block: Block) -> Bool {
        block.x >= 0 && block.x < columns && block.y < rows
    }
    
    private func movePiece(deltaX: Int) {
        guard let piece = currentPiece else { return }
        let newPosition = CGPoint(x: piece.position.x + CGFloat(deltaX), y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
            updateBoard()
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
