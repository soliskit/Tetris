//
//  TetrisGameView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct TetrisGameView: View {
    @AppStorage("highScore") private var highScore: Int = 0
    @State var gameState = GameState()
    
    var body: some View {
        VStack {
            // MARK: - Score
            Text("Score: \(gameState.score)")
                .font(.headline)
            Text("High Score: \(highScore)")
                .font(.caption)
            
            // MARK: - Next Piece
            HStack {
                PiecePreviewView(label: "Hold", piece: gameState.heldPiece)
                    .onTapGesture {
                        gameState.holdOrSwitchPiece()
                    }
                Spacer()
                PiecePreviewView(label: "Next", piece: gameState.nextPiece)
            }
            
            // MARK: - Game Board
            GameBoardView(gameState: gameState)
                .aspectRatio(0.5, contentMode: .fit)
                .padding()
                .background(.black.opacity(0.5))
                .cornerRadius(10)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { gesture in
                            if abs(gesture.translation.width) > abs(gesture.translation.height) {
                                // Horizontal move
                                if gesture.translation.width < 0 {
                                    gameState.movePieceLeft()
                                } else {
                                    gameState.movePieceRight()
                                }
                            } else {
                                // Vertical move, but we only care about downward swipes here
                                if gesture.translation.height > 0 {
                                    gameState.dropPiece()
                                }
                            }
                        }
                )
                .onTapGesture {
                    gameState.rotatePiece()
                }
            
            // MARK: - Game Start, Pause & Resume Button
            if gameState.isGameOver {
                Button("Start New Game") {
                    gameState.startGame()
                }
                .padding()
                .background(.indigo)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                .padding()
            } else {
                Button(gameState.isPaused ? "Resume" : "Pause") {
                    gameState.togglePauseResume()
                }
                .padding()
                .background(.indigo)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                .padding()
            }
        }
        .padding()
        .background(.teal.opacity(0.75))
        .background {
            KeyboardInputView(moveLeft: gameState.movePieceLeft, moveRight: gameState.movePieceRight, rotate: gameState.rotatePiece, drop: gameState.dropPiece, hold: gameState.holdOrSwitchPiece)
        }
        .cornerRadius(20)
        .padding()
        .onAppear {
            gameState.startGame()
        }
        .onChange(of: gameState.isGameOver) {
            if gameState.score > highScore {
                highScore = gameState.score
            }
        }
    }
}

#Preview("Tetris Game") {
    TetrisGameView(gameState: GameState())
}
