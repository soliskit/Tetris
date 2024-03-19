//
//  BlockView.swift
//  Tetris
//
//  Created by David Solis on 3/18/24.
//

import SwiftUI

struct BlockView: View {
    var color: Color
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: height)
            .border(Color.black.opacity(0.5), width: 0.5)
    }
}
