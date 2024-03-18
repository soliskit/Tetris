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
            if !movePiece(deltaX: 0, deltaY: 1) {
                lockPiece()
                removeCompletedLines()
                prepareNextPiece()
            }
        }
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
        if let _ = heldPiece {
            swap(&currentPiece, &heldPiece)
            currentPiece?.position = CGPoint(x: columns / 2, y: 0)
            if !isPositionValid(piece: currentPiece!, position: currentPiece!.position) {
                endGame()
            }
        } else {
            heldPiece = currentPiece
            prepareNextPiece()
        }
        isPieceHeld.toggle()
        updateBoard()
    }
    
    func movePieceLeft() {
        _ = movePiece(deltaX: -1)
    }
    
    func movePieceRight() {
        _ = movePiece(deltaX: 1)
    }
    
    func rotatePiece() {
        guard status == .playing, var piece = currentPiece else { return }
        piece.rotate()
        if isPositionValid(piece: piece, position: piece.position) {
            currentPiece = piece
            updateBoard()
        }
    }
    
    func movePieceDown() {
        let didMoveDown = movePiece(deltaX: 0, deltaY: 1)
        if !didMoveDown {
            lockPiece()
            removeCompletedLines()
            prepareNextPiece()
        }
    }
    
    // MARK: - Piece Management
        
    func prepareNextPiece() {
        guard let nextPiece = nextPiece, isPositionValid(piece: nextPiece, position: CGPoint(x: columns / 2, y: 0)) else {
            endGame()
            return
        }
        currentPiece = nextPiece
        self.nextPiece = TetrisPieceFactory.createPiece(columns: columns)
    }

    private func lockPiece() {
        guard let piece = currentPiece else { return }
        let blocksToLock = piece.generateBlocks().map { block -> Block in
            var lockedBlock = block
            lockedBlock.isLocked = true
            return lockedBlock
        }
        blocks.removeAll { !$0.isLocked && $0.parentPieceID == piece.id }
        blocks.append(contentsOf: blocksToLock)
        removeCompletedLines()
        if blocks.contains(where: { $0.y == 0 && $0.isLocked }) {
            endGame()
        } else {
            prepareNextPiece()
        }
        updateBoard()
    }

    private func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        let generatedBlocks = piece.generateBlocks(position: position)
        return generatedBlocks.allSatisfy { block in
            let xIndex = Int(round(block.x))
            let yIndex = Int(round(block.y))
            let isInBounds = xIndex >= 0 && xIndex < columns && yIndex >= 0 && yIndex < rows
            let isSpaceEmpty = !blocks.contains { lockedBlock in
                Int(round(lockedBlock.x)) == xIndex && Int(round(lockedBlock.y)) == yIndex && lockedBlock.isLocked
            }
            return isInBounds && isSpaceEmpty
        }
    }
    
    // MARK: - Board & Score Management
    
    func updateBoard() {
        guard status == .playing else { return }
        clearBoard()
        var visualizationBlocks: [Block] = []
        for block in blocks where block.isLocked {
            let xIndex = Int(round(block.x))
            let yIndex = Int(round(block.y))
            if xIndex >= 0, xIndex < columns, yIndex >= 0, yIndex < rows {
                board[yIndex][xIndex] = block
                visualizationBlocks.append(block)
            }
        }
        if let piece = currentPiece, isPositionValid(piece: piece, position: piece.position) {
            let pieceBlocks = piece.generateBlocks().map { block -> Block in
                return Block(x: block.x, y: block.y, color: block.color, isLocked: false, parentPieceID: piece.id)
            }
            visualizationBlocks.append(contentsOf: pieceBlocks)
        }
        blocks = visualizationBlocks
    }

    private func removeCompletedLines() {
        let completedLinesIndices = (0..<rows).filter { rowIndex in
            board[rowIndex].allSatisfy { $0 != nil && $0!.isLocked }
        }
        score += completedLinesIndices.count * 100
        for rowIndex in completedLinesIndices.reversed() {
            board.remove(at: rowIndex)
            board.insert(Array(repeating: nil, count: columns), at: 0)
            blocks.removeAll { block in
                Int(round(block.y)) == rowIndex && block.isLocked
            }
            blocks = blocks.map { block in
                var newBlock = block
                if Int(round(block.y)) < rowIndex {
                    newBlock.y += 1
                }
                return newBlock
            }
        }
        updateBoard()
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
    
    func movePiece(deltaX: Int, deltaY: Int = 0) -> Bool {
        guard let piece = currentPiece else { return false }
        let newPosition = CGPoint(x: piece.position.x + CGFloat(deltaX), y: piece.position.y + CGFloat(deltaY))
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
            updateBoard()
            return true
        }
        return false
    }
}

enum GameStateStatus {
    case ready, playing, paused, gameOver
}
