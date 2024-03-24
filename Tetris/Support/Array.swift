//
//  Array.swift
//  Tetris
//
//  Created by David Solis on 3/21/24.
//

import Foundation

extension Array where Element: Collection, Element.Index == Int {
    subscript(safeRow row: Int, safeColumn column: Int) -> Element.Element? {
        guard row >= 0, row < count, column >= 0, column < self[row].count else {
            return nil
        }
        return self[row][column]
    }
}
