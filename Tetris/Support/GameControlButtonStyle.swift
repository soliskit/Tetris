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
            .background(configuration.isPressed ? .indigo.opacity(0.5) : .indigo)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .font(.headline)
    }
}
