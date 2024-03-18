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
        if let held = heldPiece {
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
        currentPiece = nextPiece ?? TetrisPieceFactory.createPiece(columns: columns)
        nextPiece = TetrisPieceFactory.createPiece(columns: columns)
        guard let currentPiece = currentPiece, isPositionValid(piece: currentPiece, position: currentPiece.position) else {
            endGame()
            return
        }
        updateBoard()
    }

    private func lockPiece() {
        guard let piece = currentPiece else { return }
        let blocksToAdd = piece.generateBlocks()
        blocks.append(contentsOf: blocksToAdd)
        blocksToAdd.forEach { block in
            board[block.y][block.x] = block
        }
        removeCompletedLines()
        if blocks.contains(where: { $0.y == 0 }) {
            endGame()
        } else {
            prepareNextPiece()
        }
    }
    
    private func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        let generatedBlocks = piece.generateBlocks(position: position)
        return generatedBlocks.allSatisfy { block in
            let isInBounds = block.x >= 0 && block.x < columns && block.y >= 0 && block.y < rows
            let isSpaceEmpty = board[block.y][block.x] == nil || lockedBlocks.contains(where: { $0.x == block.x && $0.y == block.y })
            return isInBounds && isSpaceEmpty
        }
    }
    
    // MARK: - Board & Score Management
    
    func updateBoard() {
        guard status == .playing, let piece = currentPiece else { return }
        clearBoard()
        blocks.forEach { block in
            board[block.y][block.x] = block
        }
        if isPositionValid(piece: piece, position: piece.position) {
            piece.generateBlocks().forEach { block in
                board[block.y][block.x] = block
            }
        }
    }

    private func removeCompletedLines() {
        let completedLines = board
            .enumerated()
            .filter { $1.allSatisfy { $0 != nil } }
            .map { $0.offset }
        completedLines.forEach { rowIndex in
            board.remove(at: rowIndex)
            board.insert(Array(repeating: nil, count: columns), at: 0)
        }
        score += completedLines.count * 100
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
