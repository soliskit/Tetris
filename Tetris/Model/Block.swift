//
//  Block.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct Block: Identifiable {
    let id = UUID()
    var x: Int
    var y: Int
    var color: Color
}
