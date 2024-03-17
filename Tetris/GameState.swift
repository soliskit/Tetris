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
    private var gameTimer: Timer?
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
    
    @objc private func gameTick() {
        guard !isGameOver, !isPaused, let piece = currentPiece else { return }
        if !movePieceDown() {
            lockPiece()
            removeCompletedLines()
            prepareNextPiece()
        }
    }
    
    func togglePauseResume() {
        isPaused.toggle()
        if isPaused {
            gameTimer?.invalidate()
        } else {
            gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gameTick), userInfo: nil, repeats: true)
        }
    }
    
    func startGame() {
        resetGameState()
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gameTick), userInfo: nil, repeats: true)
    }
    
    private func gameOver() {
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    // MARK: - Piece Management
    
    private func prepareNextPiece() {
        if heldPiece == nil || !isPieceHeld {
            currentPiece = nextPiece ?? TetrisPieceFactory.createPiece(columns: columns)
        }
        nextPiece = TetrisPieceFactory.createPiece(columns: columns)
        isPieceHeld = false
        
        if !isPositionValid(piece: currentPiece!, position: currentPiece!.position) {
            gameOver()
        }
        updateBoardWithCurrentPiece()
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
    
    private func movePieceDown() -> Bool {
        guard let piece = currentPiece else { return false }
        let newPosition = CGPoint(x: piece.position.x, y: piece.position.y + 1)
        
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
            updateBoardWithCurrentPiece()
            return true
        } else {
            return false
        }
    }
    
    func movePieceLeft() {
        movePiece(deltaX: -1)
    }
    
    func movePieceRight() {
        movePiece(deltaX: 1)
    }
    
    private func movePiece(deltaX: Int) {
        guard let piece = currentPiece, !isGameOver else { return }
        let newPosition = CGPoint(x: piece.position.x + CGFloat(deltaX), y: piece.position.y)
        if isPositionValid(piece: piece, position: newPosition) {
            currentPiece?.position = newPosition
        }
    }
    
    func rotatePiece() {
        guard var piece = currentPiece, !isGameOver else { return }
        piece.rotate()
        if isPositionValid(piece: piece, position: piece.position) {
            currentPiece = piece
        }
    }
    
    func dropPiece() {
        while movePieceDown() {}
        gameTick()
    }
    
    // MARK: - Board & Score Management
    
    private func updateBoardWithCurrentPiece() {
        clearBoard()
        if let piece = currentPiece {
            let blocks = piece.generateBlocks()
            for block in blocks where block.y >= 0 && block.y < rows && block.x >= 0 && block.x < columns {
                board[block.y][block.x] = block
            }
        }
        for block in blocks {
            if block.y >= 0 && block.y < rows && block.x >= 0 && block.x < columns {
                board[block.y][block.x] = block
            }
        }
    }
    
    private func clearBoard() {
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }
    
    private func updateBoardWithLockedBlocks() {
        clearBoard()
        for block in blocks {
            if block.y >= 0 && block.y < rows && block.x >= 0 && block.x < columns {
                board[block.y][block.x] = block
            }
        }
    }
    
    private func lockPiece() {
        guard let piece = currentPiece else { return }
        let blocksToAdd = piece.generateBlocks()
        blocks.append(contentsOf: blocksToAdd)
        currentPiece = nil
        updateBoardWithLockedBlocks()
    }
    
    private func removeCompletedLines() {
        let completedLineIndices = board.indices.filter { row in
            board[row].allSatisfy { $0 != nil }
        }
        guard !completedLineIndices.isEmpty else { return }
        completedLineIndices.reversed().forEach { index in
            board.remove(at: index)
        }
        board.insert(contentsOf: Array(repeating: Array(repeating: nil, count: columns), count: completedLineIndices.count), at: 0)
        
        applyScoring(linesRemoved: completedLineIndices.count)
    }
    
    private func applyScoring(linesRemoved: Int) {
        let pointsPerLine = 100
        let scoreBonus = linesRemoved * pointsPerLine
        score += scoreBonus
    }
    
    private func isPositionValid(piece: TetrisPiece, position: CGPoint) -> Bool {
        let coordinatesWithBlocks = piece.shape
            .enumerated()
            .flatMap { y, row -> [(x: Int, y: Int, block: Bool)] in
                row.enumerated().map { x, block in (x: x + Int(position.x), y: y + Int(position.y), block: block) }
            }
            .filter { $0.block }
        return coordinatesWithBlocks.allSatisfy { coordinate in
            let (x, y, _) = coordinate
            let isInBounds = x >= 0 && x < columns && y < rows
            let noOverlap = y < 0 || board.indices.contains(y) && board[y].indices.contains(x) && board[y][x] == nil
            return isInBounds && noOverlap
        }
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
        prepareNextPiece()
    }
}
