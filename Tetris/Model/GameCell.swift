//
//  GameCell.swift
//  Tetris
//
//  Created by David Solis on 3/20/24.
//

import SwiftUI

struct GameCell: Identifiable {
    let id = UUID()
    var isFilled: Bool = false
    var color: Color? = nil
}
