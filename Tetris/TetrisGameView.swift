//
//  TetrisGameView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrisGameView: View {
    @State var gameState = GameState()
    
    var body: some View {
        VStack {
            // MARK: - Score
            Text("Score: \(gameState.score)")
                .font(.title)
                .padding()
            
            // MARK: - Game Board
            GameBoardView(gameState: gameState)
                .aspectRatio(0.5, contentMode: .fit)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
            
            // MARK: - Game Controls
            HStack {
                
                Button {
                    gameState.movePieceLeft()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
                
                Button {
                    gameState.movePieceRight()
                } label: {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
                
                Button {
                    gameState.rotatePiece()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
                
                Button {
                    gameState.dropPiece()
                } label: {
                    Image(systemName: "arrow.down.to.line")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .buttonStyle(GameControlButtonStyle())
            }
            .padding(.top, 20)
            
            // MARK: - New Game Button
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
