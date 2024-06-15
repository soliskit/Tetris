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
        VStack {
            Text("Score: \(gameManager.score)")
                .font(.headline)
            Text("High Score: \(highScore)")
                .font(.caption)
            
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
                .padding()
                .background(.black.opacity(0.5))
                .cornerRadius(10)
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
        .background(.teal.opacity(0.75))
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
