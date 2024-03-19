//
//  TetrominoFactory.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import Foundation

struct TetrominoFactory {
    static func generate() -> [Block] {
        let shapeIndex = Int.random(in: 0..<7)
        let center = 10 / 2
        let startY = -1
        
        switch shapeIndex {
            case 0: // I
                return [
                    Block(x: center - 2, y: startY, color: .cyan),
                    Block(x: center - 1, y: startY, color: .cyan),
                    Block(x: center, y: startY, color: .cyan),
                    Block(x: center + 1, y: startY, color: .cyan)
                ]
            case 1: // O
                return [
                    Block(x: center, y: startY, color: .yellow),
                    Block(x: center + 1, y: startY, color: .yellow),
                    Block(x: center, y: startY + 1, color: .yellow),
                    Block(x: center + 1, y: startY + 1, color: .yellow)
                ]
            case 2: // T
                return [
                    Block(x: center - 1, y: startY, color: .purple),
                    Block(x: center, y: startY, color: .purple),
                    Block(x: center + 1, y: startY, color: .purple),
                    Block(x: center, y: startY + 1, color: .purple)
                ]
            case 3: // S
                return [
                    Block(x: center, y: startY, color: .green),
                    Block(x: center + 1, y: startY, color: .green),
                    Block(x: center - 1, y: startY + 1, color: .green),
                    Block(x: center, y: startY + 1, color: .green)
                ]
            case 4: // Z
                return [
                    Block(x: center - 1, y: startY, color: .red),
                    Block(x: center, y: startY, color: .red),
                    Block(x: center, y: startY + 1, color: .red),
                    Block(x: center + 1, y: startY + 1, color: .red)
                ]
            case 5: // J
                return [
                    Block(x: center - 1, y: startY, color: .blue),
                    Block(x: center - 1, y: startY + 1, color: .blue),
                    Block(x: center, y: startY + 1, color: .blue),
                    Block(x: center + 1, y: startY + 1, color: .blue)
                ]
            case 6: // L
                return [
                    Block(x: center + 1, y: startY, color: .orange),
                    Block(x: center - 1, y: startY + 1, color: .orange),
                    Block(x: center, y: startY + 1, color: .orange),
                    Block(x: center + 1, y: startY + 1, color: .orange)
                ]
            default:
                fatalError("Index out of range")
        }
    }
}
