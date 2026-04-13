//
//  ContentView.swift
//  Tetris
//
//  Created by David Solis on 6/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var gameManager = GameManager()
    @AppStorage("highScore") private var highScore: Int = 0
    @State private var dragCellOffset: Int = 0
    @State private var dragRowOffset: Int = 0
    @State private var cellWidth: CGFloat = 32
    @State private var horizontalDragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            MeshGradient(
                width: 3, height: 3,
                points: [
                    SIMD2(0.0, 0.0), SIMD2(0.5, 0.0), SIMD2(1.0, 0.0),
                    SIMD2(0.0, 0.5), SIMD2(0.5, 0.5), SIMD2(1.0, 0.5),
                    SIMD2(0.0, 1.0), SIMD2(0.5, 1.0), SIMD2(1.0, 1.0)
                ],
                colors: [
                    .indigo, .purple, .blue,
                    .blue, .cyan, .indigo,
                    .purple, .blue, .teal
                ]
            )
            .ignoresSafeArea()

            GlassEffectContainer {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Score: \(gameManager.score)")
                            .font(.title2.bold().monospacedDigit())
                        Text("High Score: \(highScore)")
                            .font(.caption.monospacedDigit())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .glassEffect(.regular, in: .capsule)

                    HStack {
                        TetrominoPreview(tetromino: gameManager.heldTetromino)
                            .onTapGesture {
                                gameManager.handleAction(.hold)
                            }
                        Spacer()
                        TetrominoPreview(tetromino: gameManager.nextTetromino)
                    }

                    GameBoardView(gameManager: gameManager, horizontalDragOffset: horizontalDragOffset)
                        .aspectRatio(0.5, contentMode: .fit)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.width / 10
                        } action: { newValue in
                            cellWidth = newValue
                        }
                        .padding(8)
                        .glassEffect(.regular, in: .rect(cornerRadius: 20))
                        .gesture(
                            DragGesture(minimumDistance: 3)
                                .onChanged { gesture in
                                    let newColOffset = Int(gesture.translation.width / cellWidth)
                                    let colDelta = newColOffset - dragCellOffset
                                    if colDelta != 0 {
                                        let action: PlayerAction = colDelta > 0 ? .moveRight : .moveLeft
                                        for _ in 0..<abs(colDelta) {
                                            gameManager.handleAction(action)
                                        }
                                        dragCellOffset = newColOffset
                                    }

                                    // Fractional offset within the current cell for smooth visual tracking
                                    let fractional = gesture.translation.width - CGFloat(dragCellOffset) * cellWidth
                                    // Clamp to half a cell so it doesn't visually overshoot
                                    horizontalDragOffset = max(-cellWidth * 0.5, min(cellWidth * 0.5, fractional))

                                    let newRowOffset = max(0, Int(gesture.translation.height / cellWidth))
                                    let rowDelta = newRowOffset - dragRowOffset
                                    if rowDelta > 0 {
                                        for _ in 0..<rowDelta {
                                            gameManager.softDrop()
                                        }
                                        dragRowOffset = newRowOffset
                                    }
                                }
                                .onEnded { _ in
                                    dragCellOffset = 0
                                    dragRowOffset = 0
                                    withAnimation(.interpolatingSpring(duration: 0.08, bounce: 0)) {
                                        horizontalDragOffset = 0
                                    }
                                }
                        )
                        .onTapGesture {
                            gameManager.handleAction(.rotate)
                        }

                    ButtonView(gameManager: gameManager)
                }
                .padding()
            }
        }
        .background {
            KeyboardInputView(
                moveLeft: { gameManager.handleAction(.moveLeft) },
                moveRight: { gameManager.handleAction(.moveRight) },
                rotate: { gameManager.handleAction(.rotate) },
                drop: { gameManager.handleAction(.drop) },
                hold: { gameManager.handleAction(.hold) }
            )
        }
    }
}

#Preview("Content View") {
    ContentView(gameManager: GameManager())
}
