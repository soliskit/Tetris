//
//  Tetromino.swift
//  Tetris
//
//  Created by David Solis on 3/20/24.
//

import SwiftUI

struct Tetromino: Identifiable {
    let id = UUID()
    var shape: [[Bool]]
    var color: Color
    var position: Position
    var rotationState: Int = 0
    var rotationPoints: [[[Int]]]
    var wallKickData: [[CGPoint]]
    
    mutating func rotate(gameBoard: [[GameCell]]) {
        let previousState = rotationState
        rotationState = (rotationState + 1) % 4
        let newShape = rotatedShape()
        
        if isWithinBoundsAndNotColliding(for: newShape, atRow: position.row, andColumn: position.column, gameBoard: gameBoard) {
            if !applyWallKick(from: previousState, to: rotationState, gameBoard: gameBoard) {
                rotationState = previousState
            } else {
                shape = newShape
            }
        } else {
            shape = newShape
        }
    }
    
    private mutating func applyWallKick(from previousState: Int, to nextState: Int, gameBoard: [[GameCell]]) -> Bool {
        let kickIndex = previousState * 4 + nextState
        guard wallKickData.indices.contains(kickIndex) else { return false }
        return wallKickData[kickIndex].contains { kickPosition in
            let testRow = position.row + kickPosition.y
            let testColumn = position.column + kickPosition.x
            if !isWithinBoundsAndNotColliding(for: shape, atRow: testRow, andColumn: testColumn, gameBoard: gameBoard) {
                position.row += kickPosition.y
                position.column += kickPosition.x
                return true
            }
            return false
        }
    }
    
    private func rotatedShape() -> [[Bool]] {
        let size = shape.count
        return (0..<size).map { row in
            (0..<size).map { col in
                shape[col][size - row - 1]
            }
        }
    }
    
    private func checksCollision(for shape: [[Bool]], atRow row: CGFloat, andColumn column: CGFloat) -> Bool {
        let boardRows = 20
        let boardColumns = 10
        return shape.enumerated().contains { (shapeRow, rowContents) in
            rowContents.enumerated().contains { (shapeColumn, isOccupied) in
                isOccupied && {
                    let boardRow = Int(row) + shapeRow
                    let boardColumn = Int(column) + shapeColumn
                    return boardRow < 0 || boardRow >= boardRows || boardColumn < 0 || boardColumn >= boardColumns
                }()
            }
        }
    }
    
    private func isWithinBoundsAndNotColliding(for newShape: [[Bool]], atRow: CGFloat, andColumn: CGFloat, gameBoard: [[GameCell]]) -> Bool {
        !newShape.enumerated().contains { rowIndex, row in
            row.enumerated().contains { columnIndex, isFilled in
                if isFilled {
                    let boardRow = Int(atRow) + rowIndex
                    let boardColumn = Int(andColumn) + columnIndex
                    
                    return boardRow < 0 || boardRow >= 20 || boardColumn < 0 || boardColumn >= 10 ||
                    (gameBoard.indices.contains(boardRow) && gameBoard[boardRow].indices.contains(boardColumn) && gameBoard[boardRow][boardColumn].isFilled)
                }
                return false
            }
        }
    }
}
