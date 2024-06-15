//
//  Position.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import Foundation

/// Represents the position of a game element within the game grid.
///
/// This struct is used to track the location of tetrominos in a grid-based game like Tetris.
/// The position is defined in terms of `row` and `column`, corresponding to the grid's coordinates.
struct Position: Equatable, Codable {
    /// The vertical position in the grid, with 0 being the topmost row.
    var row: Int
    /// The horizontal position in the grid, with 0 being the leftmost column.
    var column: Int
}
