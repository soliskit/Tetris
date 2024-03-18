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
    var board: [[Block?]] = Array(repeating: Array(repeating: nil, count: 10), count: 20)
    private(set) var blocks: [Block] = []
    private(set) var currentPiece: TetrisPiece?
    private(set) var heldPiece: TetrisPiece?
    private(set) var nextPiece: TetrisPiece?
    private(set) var isPieceHeld: Bool = false
    private(set) var status: GameStateStatus = .ready
    private(set) var score: Int = 0
    
    var isCurrentPositionValid: Bool {
        if let currentPiece = currentPiece {
            return isPositionValid(piece: currentPiece, position: currentPiece.position)
        }
        return false
    }
    
    // MARK: - Game Session
    
    func startGame() {
        assert(status == .ready || status == .gameOver, "startGame called but game is not ready or already over.")
        prepareNewGame()
        status = .playing
        setupGameTimer()
    }
    
    private func endGame() {
        status = .gameOver
        gameTimer?.invalidate()
    }
    
    func togglePauseResume() {
        switch status {
            case .playing:
                gameTimer?.invalidate()
                status = .paused
            case .paused:
                status = .playing
                setupGameTimer()
            default:
                break
        }
    }

    @objc private func handleGameTick() {
        assert(Thread.isMainThread, "handleGameTick must be executed on the main thread.")
        guard status == .playing else { return }
        let currentTime = Date().timeIntervalSinceReferenceDate
        if let lastUpdateTime = self.lastUpdateTime {
            timeSinceLastDrop += currentTime - lastUpdateTime
        }
        self.lastUpdateTime = currentTime
        
        if timeSinceLastDrop >= dropDelay {
            timeSinceLastDrop = 0
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
            self?.handleGameTick()
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
        guard status == .playing, var piece = currentPiece else { return }
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
            endGame()
        } else {
            updateBoard()
        }
    }

    
    func movePieceDown() -> Bool {
        guard var currentPiece = currentPiece else { return false }
        let newPosition = CGPoint(x: currentPiece.position.x, y: currentPiece.position.y + 1)
        let blocksAtNewPosition = currentPiece.generateBlocks(position: newPosition)
        let canMoveDown = blocksAtNewPosition.allSatisfy { block in
            withinBounds(block: block) && board[block.y][block.x] == nil
        }
        if canMoveDown {
            currentPiece.position = newPosition
            updateBoard()
            return true
        } else {
            if canLockPiece(currentPiece) {
                lockPiece()
                return false
            } else {
                endGame()
                return false
            }
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
            endGame()
            return
        }
        currentPiece = nil
        removeCompletedLines()
        prepareNextPiece()
        updateBoard()
    }
    
    private func canLockPiece(_ piece: TetrisPiece) -> Bool {
        let nextDownPosition = CGPoint(x: piece.position.x, y: piece.position.y + 1)
        let isValidNextDownPosition = isPositionValid(piece: piece, position: nextDownPosition)
        
        return !isValidNextDownPosition
    }
    
    func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        let generatedBlocks = piece.generateBlocks(position: position)
        
        return generatedBlocks.allSatisfy { block in
            let withinBounds = block.x >= 0 && block.x < columns && block.y >= 0 && block.y < rows
            let positionNotOccupied = board[block.y][block.x] == nil || board[block.y][block.x]?.parentPieceID == piece.id
            let notOverlappingNextPosition = block.y + 1 < rows && (!blocks.contains { otherBlock in
                otherBlock.x == block.x && otherBlock.y == block.y + 1 && otherBlock.parentPieceID != piece.id
            })
            return withinBounds && positionNotOccupied && notOverlappingNextPosition
        }
    }
    
    // MARK: - Board & Score Management
    
    func updateBoard() {
        guard status == .playing else { return }
        clearBoard()
        for block in blocks where withinBounds(block: block) {
            board[block.y][block.x] = block
        }
        guard let piece = currentPiece else { return }
        for block in piece.generateBlocks() where withinBounds(block: block) {
            board[block.y][block.x] = block
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
    
    // MARK: - Helper Methods
    
    private func clearBoard() {
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }
    
    func prepareNewGame() {
        status = .ready
        score = 0
        blocks.removeAll()
        currentPiece = TetrisPieceFactory.createPiece(columns: columns)
        nextPiece = TetrisPieceFactory.createPiece(columns: columns)
        isPieceHeld = false
        heldPiece = nil
        timeSinceLastDrop = 0
        lastUpdateTime = nil
        clearBoard()
        updateBoard()
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
}

enum GameStateStatus {
    case ready, playing, paused, gameOver
}
