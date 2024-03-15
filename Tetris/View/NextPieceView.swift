//
//  NextPieceView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct NextPieceView: View {
    var piece: TetrisPiece
    
    // Define the size of each block in the next piece preview
    private let blockSize: CGFloat = 20
    
    var body: some View {
        VStack {
            ForEach(0..<piece.shape.count, id: \.self) { row in
                HStack {
                    ForEach(0..<piece.shape[row].count, id: \.self) { column in
                        if piece.shape[row][column] {
                            Rectangle()
                                .frame(width: blockSize, height: blockSize)
                                .foregroundColor(piece.color)
                        } else {
                            Rectangle()
                                .frame(width: blockSize, height: blockSize)
                                .foregroundColor(.clear)
                        }
                    }
                }
            }
        }
        .padding(5)
        .background(Color.black.opacity(0.5)) // Optionally add a background
        .cornerRadius(5)
    }
}

#Preview {
    NextPieceView(piece: TetrisPiece(position: CGPoint(x: 10 / 2 - 1, y: 0), color: .yellow, rotations: [
        [[true, true], [true, true]]
    ]))
}
