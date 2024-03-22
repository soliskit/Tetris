//
//  PlayerAction.swift
//  Tetris
//
//  Created by David Solis on 3/19/24.
//

import Foundation

/// Represents actions a player can take during the game.
///
/// This enum encapsulates the different types of inputs a player can provide while playing.
/// It includes movements and rotations of the current tetromino, holding a tetromino, and game control actions like pausing and resuming the game.
enum PlayerAction {
    /// Move the Tetromino one unit to the left.
    case moveLeft
    /// Move the Tetromino one unit to the right.
    case moveRight
    /// Hold the current Tetromino to swap it with the next one.
    case hold
    /// Changes the orientation of the tetromino, allowing it to fit into different spaces on the game board.
    case rotate
    /// Speeds up the descent of the current tetromino, allowing players to place it more quickly.
    case drop
    /// Freezes the game state, allowing players to take a break or plan their next moves.
    case pause
    /// Returns the game to its active state, continuing from where it was paused.
    case resume
}
