//
//  PlayerAction.swift
//  Tetris
//
//  Created by David Solis on 3/19/24.
//

import Foundation

/// Represents actions a player can take during the game.
enum PlayerAction {
    /// Move the Tetromino one unit to the left.
    case moveLeft
    /// Move the Tetromino one unit to the right.
    case moveRight
    /// Hold the current Tetromino to swap it with the next one.
    case hold
    /// Soft drop the Tetromino, making it fall faster.
    case softDrop
    /// Pause the game.
    case pause
    /// Start or restart the game.
    case start
}
