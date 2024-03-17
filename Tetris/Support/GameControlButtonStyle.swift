//
//  GameControlButtonStyle.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct GameControlButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(.indigo.opacity(configuration.isPressed ? 0.5 : 0.2))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
