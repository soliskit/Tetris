//
//  ButtonView.swift
//  Tetris
//
//  Created by David Solis on 3/21/24.
//

import SwiftUI

struct ButtonView: View {
    var gameManager: GameManager
    
    var body: some View {
        if gameManager.state == .gameOver {
            Button("Start Game") {
                gameManager.startGame()
            }
            .buttonStyle(GameControlButtonStyle())
        } else {
            Button(gameManager.state == .playing ? "Pause" : "Resume") {
                if gameManager.state == .playing {
                    gameManager.handleAction(.pause)
                } else {
                    gameManager.handleAction(.resume)
                }
            }
            .buttonStyle(GameControlButtonStyle())
        }
    }
}

#Preview {
    ButtonView(gameManager: GameManager())
}
