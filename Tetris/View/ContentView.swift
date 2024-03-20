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
            Text("State: \(gameManager.state)")
                .font(.headline)
            Text("High Score: \(highScore)")
                .font(.caption)
            
            HStack {
                TetrominoPreview(tetromino: gameManager.heldPiece)
                Spacer()
                TetrominoPreview(tetromino: gameManager.nextPiece)
            }
            
            GameBoardView(gameManager: gameManager)
                .aspectRatio(0.5, contentMode: .fit)
                .padding()
                .background(.black.opacity(0.5))
                .cornerRadius(10)
            if gameManager.state == .gameOver {
                Button("Start Game") {
                    gameManager.startGame()
                }
            } else {
                Button(gameManager.state == .playing ? "Pause" : "Start") {
                    if gameManager.state == .playing {
                        gameManager.handleAction(.pause)
                    } else {
                        gameManager.handleAction(.resume)
                    }
                }
            }
        }
        .padding()
        .background(.teal.opacity(0.75))
    }
}

#Preview("Content View") {
    ContentView(gameManager: GameManager())
}

