//
//  ButtonView.swift
//  Tetris
//
//  Created by David Solis on 3/21/24.
//

import SwiftUI

struct ButtonView: View {
    @AppStorage("isSessionSaved") private var isSessionSaved: Bool = false
    var gameManager: GameManager
    
    var body: some View {
        HStack {
            if gameManager.state == .gameOver {
                Button("New Game") {
                    Task { await gameManager.handleAction(.newGame) }
                }
                .buttonStyle(GameControlButtonStyle())
                if isSessionSaved {
                    Button("Continue") {
                        Task { await gameManager.handleAction(.continueGame) }
                    }
                    .buttonStyle(GameControlButtonStyle())
                }
            } else {
                Spacer()
                if gameManager.state == .paused {
                    Button(action: {
                        Task { await gameManager.handleAction(.resume) }
                    }, label: {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    })
                } else if gameManager.state == .playing {
                    Button(action: {
                        Task { await gameManager.handleAction(.pause) }
                    }, label: {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    })
                }
            }
        }
    }
}

#Preview("Button View") {
    ButtonView(gameManager: GameManager())
}
