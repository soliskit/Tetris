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
    private var gameTimer: Timer?
    private var lastUpdateTime: TimeInterval?
    private var timeSinceLastDrop: TimeInterval = 0
    private var dropDelay: TimeInterval = 0.5
    let rows = 20
    let columns = 10
    var board: [[Block?]]
    var blocks: [Block] = []
    var currentPiece: TetrisPiece?
    var heldPiece: TetrisPiece?
    var isPieceHeld: Bool = false
    var nextPiece: TetrisPiece?
    var isPaused: Bool = false
    var isGameOver: Bool = true
    var score: Int = 0
    
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
            lastUpdateTime = nil
            gameTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(gameTick), userInfo: nil, repeats: true)
        }
    }
    
    func startGame() {
        resetGameState()
        lastUpdateTime = Date().timeIntervalSinceReferenceDate
        gameTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(gameTick), userInfo: nil, repeats: true)
    }
    
    private func gameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    @objc private func gameTick() {
        guard let lastUpdateTime = lastUpdateTime else {
            self.lastUpdateTime = Date().timeIntervalSinceReferenceDate
            return
        }
        let currentTime = Date().timeIntervalSinceReferenceDate
        let deltaTime = currentTime - lastUpdateTime
        self.lastUpdateTime = currentTime
        guard !isGameOver, !isPaused else { return }
        
        timeSinceLastDrop += deltaTime
        if timeSinceLastDrop >= dropDelay {
            timeSinceLastDrop = 0
            if !movePieceDown() {
                lockPiece()
                removeCompletedLines()
                prepareNextPiece()
            }
            updateBoard()
        }
    }
    
    private func updateGameState() {
        guard !isGameOver, !isPaused, currentPiece != nil else {
            prepareNextPiece()
            return
        }
        
        if !movePieceDown() {
            lockPiece()
            removeCompletedLines()
            prepareNextPiece()
        }
        updateBoard()
    }
    
    // MARK: - Piece Movement & Rotation
    
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
    
    private func movePiece(deltaX: Int) {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x + CGFloat(deltaX), y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    // MARK: - Piece Management
    
    private func prepareNextPiece() {
        if !isPieceHeld, let next = nextPiece {
            currentPiece = next
        } else {
            currentPiece = TetrisPieceFactory.createPiece(columns: columns)
        }
        nextPiece = TetrisPieceFactory.createPiece(columns: columns)
        isPieceHeld = false
        if let currentPiece = currentPiece, !isPositionValid(piece: currentPiece, position: currentPiece.position) {
            gameOver()
        } else {
            updateBoard()
        }
    }
    
    private func movePieceDown() -> Bool {
        guard let piece = currentPiece else { return false }
        let newPosition = CGPoint(x: piece.position.x, y: piece.position.y + 1)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
            return true
        }
        return false
    }
    
    private func lockPiece() {
        guard let piece = currentPiece else { return }
        blocks.append(contentsOf: piece.generateBlocks())
        currentPiece = nil
        removeCompletedLines()
    }
    
    // MARK: - Board & Score Management
    
    private func updateBoard() {
        clearBoard()
        (currentPiece?.generateBlocks() ?? [] + blocks)
            .filter { block in
                block.y >= 0 && block.y < rows && block.x >= 0 && block.x < columns
            }
            .forEach { block in
                board[block.y][block.x] = block
            }
    }
    
    private func removeCompletedLines() {
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
    
    private func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        piece.generateBlocks().allSatisfy { block in
            withinBounds(block: block) && (board[block.y][block.x] == nil || blocks.contains(where: { $0.id == block.id }))
        }
    }
    
    private func clearBoard() {
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }
    
    private func withinBounds(block: Block) -> Bool {
        block.x >= 0 && block.x < columns && block.y < rows
    }
    
    // MARK: - Helper Functions
    
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
        timeSinceLastDrop = 0
        lastUpdateTime = nil
        prepareNextPiece()
    }
}
