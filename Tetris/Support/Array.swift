//
//  Array.swift
//  Tetris
//
//  Created by David Solis on 3/20/24.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
