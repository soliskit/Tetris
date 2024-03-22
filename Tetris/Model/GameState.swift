//
//  GameState.swift
//  Tetris
//
//  Created by David Solis on 3/19/24.
//

import Foundation

/// Represents the current state of the game.
enum GameState {
    /// The game is currently in progress.
    case playing
    /// The game is paused.
    case paused
    /// The game is over.
    case gameOver
}
