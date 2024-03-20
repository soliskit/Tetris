//
//  ContentView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var gameManager = GameManager()
    @AppStorage("highScore") private var highScore: Int = 0
    
    var body: some View {
        VStack {
            Text("Score:")
                .font(.headline)
            Text("High Score: \(highScore)")
                .font(.caption)
            
            HStack {
//                TetrominoPreview(tetromino: gameManager.heldTetromino)
//                Spacer()
                TetrominoPreview(tetromino: gameManager.nextTetromino)
            }
            .padding()
            
            GameBoardView(gameManager: gameManager)
                .aspectRatio(0.5, contentMode: .fit)
                .padding()
                .background(.black.opacity(0.5))
                .cornerRadius(10)
                        if gameManager.gameState == .gameOver {
                            Button("Start New Game", action: gameManager.startGame)
                        } else {
                            if gameManager.gameState == .playing {
                                Button("Pause", action: gameManager.togglePauseResumeGame)
                            } else {
                                Button("Resume", action: gameManager.togglePauseResumeGame)
                            }
                        }
        }
        .onAppear {
            gameManager.startGame()
        }
        .padding()
        .background(.teal.opacity(0.75))
    }
}

#Preview("Content View") {
    ContentView(gameManager: GameManager())
}

