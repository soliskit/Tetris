//
//  ModelTests.swift
//  TetrisTests
//
//  Created by David Solis on 4/11/26.
//

import Testing
import SwiftUI
@testable import Tetris

@Suite("Models")
struct ModelTests {

    // MARK: - Position

    @Suite("Position")
    struct PositionTests {
        @Test func equality() {
            let a = Position(row: 3, column: 7)
            let b = Position(row: 3, column: 7)
            #expect(a == b)
        }

        @Test func inequality() {
            let a = Position(row: 3, column: 7)
            let b = Position(row: 4, column: 7)
            #expect(a != b)
        }

        @Test func codableRoundTrip() throws {
            let original = Position(row: 5, column: 9)
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Position.self, from: data)
            #expect(original == decoded)
        }
    }

    // MARK: - GameCell

    @Suite("GameCell")
    struct GameCellTests {
        @Test func defaultIsNotFilled() {
            let cell = GameCell()
            #expect(cell.isFilled == false)
            #expect(cell.color == nil)
        }

        @Test func filledCellRetainsColor() {
            let color = CustomColor(from: .red)
            let cell = GameCell(isFilled: true, color: color)
            #expect(cell.isFilled == true)
            #expect(cell.color == color)
        }

        @Test func equality() {
            let a = GameCell(isFilled: true, color: CustomColor(from: .blue))
            let b = GameCell(isFilled: true, color: CustomColor(from: .blue))
            #expect(a == b)
        }

        @Test func codableRoundTrip() throws {
            let original = GameCell(isFilled: true, color: CustomColor(from: .green))
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(GameCell.self, from: data)
            #expect(original == decoded)
        }
    }

    // MARK: - CustomColor

    @Suite("CustomColor")
    struct CustomColorTests {
        @Test func codableRoundTrip() throws {
            let original = CustomColor(from: .cyan)
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(CustomColor.self, from: data)
            #expect(original == decoded)
        }

        @Test func storesRGBComponents() {
            let color = CustomColor(from: Color(red: 1.0, green: 0.0, blue: 0.0))
            #expect(color.red > 0.9)
            #expect(color.green < 0.1)
            #expect(color.blue < 0.1)
            #expect(color.opacity > 0.9)
        }

        @Test func equality() {
            let a = CustomColor(from: .purple)
            let b = CustomColor(from: .purple)
            #expect(a == b)
        }

        @Test func inequality() {
            let a = CustomColor(from: .red)
            let b = CustomColor(from: .blue)
            #expect(a != b)
        }

        @Test func valueReturnsColor() {
            let custom = CustomColor(from: .orange)
            let _ = custom.value // Should not crash
        }
    }

    // MARK: - GameState

    @Suite("GameState")
    struct GameStateTests {
        @Test(arguments: [GameState.playing, .paused, .gameOver])
        func codableRoundTrip(state: GameState) throws {
            let data = try JSONEncoder().encode(state)
            let decoded = try JSONDecoder().decode(GameState.self, from: data)
            #expect(state == decoded)
        }
    }

    // MARK: - GameSession

    @Suite("GameSession")
    struct GameSessionTests {
        @Test func codableRoundTrip() throws {
            let board: [[GameCell?]] = Array(
                repeating: Array(repeating: GameCell(), count: 10),
                count: 20
            )
            let original = GameSession(
                gameBoard: board,
                score: 500,
                level: 2,
                currentTetromino: TetrominoFactory.generate(),
                nextTetromino: TetrominoFactory.generate(),
                heldTetromino: nil,
                canHoldTetromino: true
            )

            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(GameSession.self, from: data)

            #expect(decoded.score == 500)
            #expect(decoded.level == 2)
            #expect(decoded.canHoldTetromino == true)
            #expect(decoded.heldTetromino == nil)
        }

        @Test func codableRoundTripWithHeldTetromino() throws {
            let board: [[GameCell?]] = Array(
                repeating: Array(repeating: GameCell(), count: 10),
                count: 20
            )
            let held = TetrominoFactory.generate()
            let original = GameSession(
                gameBoard: board,
                score: 1200,
                level: 3,
                currentTetromino: TetrominoFactory.generate(),
                nextTetromino: TetrominoFactory.generate(),
                heldTetromino: held,
                canHoldTetromino: false
            )

            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(GameSession.self, from: data)

            #expect(decoded.score == 1200)
            #expect(decoded.level == 3)
            #expect(decoded.canHoldTetromino == false)
            #expect(decoded.heldTetromino != nil)
        }
    }

    // MARK: - Array Safe Subscript

    @Suite("Array Safe Subscript")
    struct ArraySafeSubscriptTests {
        @Test func validIndicesReturnValue() {
            let grid: [[Int]] = [[1, 2, 3], [4, 5, 6]]
            #expect(grid[safeRow: 0, safeColumn: 0] == 1)
            #expect(grid[safeRow: 1, safeColumn: 2] == 6)
        }

        @Test func negativeRowReturnsNil() {
            let grid: [[Int]] = [[1, 2], [3, 4]]
            #expect(grid[safeRow: -1, safeColumn: 0] == nil)
        }

        @Test func negativeColumnReturnsNil() {
            let grid: [[Int]] = [[1, 2], [3, 4]]
            #expect(grid[safeRow: 0, safeColumn: -1] == nil)
        }

        @Test func rowOutOfBoundsReturnsNil() {
            let grid: [[Int]] = [[1, 2], [3, 4]]
            #expect(grid[safeRow: 5, safeColumn: 0] == nil)
        }

        @Test func columnOutOfBoundsReturnsNil() {
            let grid: [[Int]] = [[1, 2], [3, 4]]
            #expect(grid[safeRow: 0, safeColumn: 5] == nil)
        }
    }

    // MARK: - PlayerAction

    @Suite("PlayerAction")
    struct PlayerActionTests {
        @Test func allCasesAreDistinct() {
            let actions: [PlayerAction] = [
                .newGame, .continueGame, .pause, .resume,
                .moveLeft, .moveRight, .hold, .rotate, .drop
            ]
            #expect(actions.count == 9)
        }
    }
}
