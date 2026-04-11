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

                    GameBoardView(gameManager: gameManager)
                        .aspectRatio(0.5, contentMode: .fit)
                        .padding(8)
                        .glassEffect(.regular, in: .rect(cornerRadius: 20))
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { gesture in
                                    if abs(gesture.translation.width) > abs(gesture.translation.height) {
                                        if gesture.translation.width < 0 {
                                            gameManager.handleAction(.moveLeft)
                                        } else {
                                            gameManager.handleAction(.moveRight)
                                        }
                                    } else {
                                        if gesture.translation.height > 0 {
                                            gameManager.handleAction(.drop)
                                        }
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
