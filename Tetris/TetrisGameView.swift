//
//  TetrisGameView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrisGameView: View {
    @StateObject var gameState = GameState()
    
    var body: some View {
        VStack {
            // Display the score
            Text("Score: \(gameState.score)")
                .font(.title)
                .padding()
            
            // Display the game board
            GameBoardView(gameState: gameState)
                .aspectRatio(0.5, contentMode: .fit)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
            
            // Game controls
            HStack {
                
                // Move piece left button
                Button(action: {
                    gameState.movePieceLeft()
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
                
                // Move piece right button
                Button(action: {
                    gameState.movePieceRight()
                }) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
                
                // Rotate piece button
                Button(action: {
                    gameState.rotatePiece()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
                
                // Move piece down (drop) button
                Button(action: {
                    gameState.dropPiece()
                }) {
                    Image(systemName: "arrow.down.to.line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
            }
            .padding(.top, 20)
            
            // Start new game button
            if gameState.isGameOver {
                Button("Start New Game") {
                    gameState.startGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                .padding()
            }
        }
        .padding()
        .background(Color.teal.opacity(0.75))
        .cornerRadius(20)
        .padding()
        .onAppear {
            gameState.startGame()
        }
    }
}

struct GameControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(Color.gray.opacity(configuration.isPressed ? 0.5 : 0.2))
            .foregroundColor(.white)
            .clipShape(Circle())
    }
}
