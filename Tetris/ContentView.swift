//
//  ContentView.swift
//  Tetris
//
//  Created by David Solis on 6/15/24.
//

import SwiftUI

struct ContentView: View {
    @State private var gameManager: GameManager? = nil
    @AppStorage("highScore") private var highScore: Int = 0
    
    var body: some View {
        VStack {
            Text("Score: \(gameManager?.score ?? 0)")
                .font(.headline)
            Text("High Score: \(highScore)")
                .font(.caption)
            
            HStack {
                TetrominoPreview(tetromino: gameManager?.heldTetromino)
                    .onTapGesture {
                        Task { await gameManager?.handleAction(.hold) }
                    }
                Spacer()
                TetrominoPreview(tetromino: gameManager?.nextTetromino)
            }
            if let gameManager = gameManager {
                GameBoardView(gameManager: gameManager)
                    .aspectRatio(0.5, contentMode: .fit)
                    .padding()
                    .background(.black.opacity(0.5))
                    .cornerRadius(10)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { gesture in
                                if abs(gesture.translation.width) > abs(gesture.translation.height) {
                                    if gesture.translation.width < 0 {
                                        Task { await gameManager.handleAction(.moveLeft) }
                                    } else {
                                        Task { await gameManager.handleAction(.moveRight) }
                                    }
                                } else {
                                    if gesture.translation.height > 0 {
                                        Task { await gameManager.handleAction(.drop) }
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        Task { await gameManager.handleAction(.rotate) }
                    }
                
                ButtonView(gameManager: gameManager)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            gameManager = GameManager()
        }
        .padding()
        .background(.teal.opacity(0.75))
        .background {
            KeyboardInputView(
                moveLeft: { Task { await gameManager?.handleAction(.moveLeft) } },
                moveRight: { Task { await gameManager?.handleAction(.moveRight) } },
                rotate: { Task { await gameManager?.handleAction(.rotate) } },
                drop: { Task { await gameManager?.handleAction(.drop) } },
                hold: { Task { await gameManager?.handleAction(.hold) } }
            )
        }
    }
}

#Preview("Content View") {
    @Previewable @State var gameManager: GameManager? = nil
    ContentView()
        .onAppear {
            gameManager = GameManager()
        }
}
