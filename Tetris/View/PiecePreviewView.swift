//
//  PiecePreviewView.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import SwiftUI

struct PiecePreviewView: View {
    let label: String
    let piece: TetrisPiece?
    
    var body: some View {
        VStack {
            Text(label)
                .font(.headline)
                .padding(.bottom, 4)
            GeometryReader { geometry in
                createPieceBlocksView(geometry: geometry)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color(white: 0.95))
        .cornerRadius(8)
    }
    
    private func calculateBlockSize(_ geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width, geometry.size.height) / CGFloat(max(piece?.shape.count ?? 1, piece?.shape.first?.count ?? 1))
    }
    
    @ViewBuilder
    private func createPieceBlocksView(geometry: GeometryProxy) -> some View {
        let blockSize = calculateBlockSize(geometry)
        let totalBlocksWidth = CGFloat(piece?.shape.first?.count ?? 0) * blockSize
        let totalBlocksHeight = CGFloat(piece?.shape.count ?? 0) * blockSize
        let xOffset = (geometry.size.width - totalBlocksWidth) / 2
        let yOffset = (geometry.size.height - totalBlocksHeight) / 2
        
        ZStack {
            ForEach(Array(piece?.shape.enumerated() ?? [].enumerated()), id: \.offset) { rowIndex, row in
                ForEach(Array(row.enumerated()), id: \.offset) { columnIndex, isFilled in
                    if isFilled {
                        PieceBlockView(color: piece?.color ?? .clear, blockSize: blockSize, columnIndex: columnIndex, rowIndex: rowIndex, xOffset: xOffset, yOffset: yOffset)
                    }
                }
            }
        }
    }
    
    struct PieceBlockView: View {
        var color: Color
        var blockSize: CGFloat
        var columnIndex: Int
        var rowIndex: Int
        var xOffset: CGFloat
        var yOffset: CGFloat
        
        var body: some View {
            Rectangle()
                .foregroundColor(color)
                .frame(width: blockSize, height: blockSize)
                .position(x: xOffset + blockSize * CGFloat(columnIndex) + blockSize / 2, y: yOffset + blockSize * CGFloat(rowIndex) + blockSize / 2)
        }
    }
}

#Preview("Piece Preview Hold") {
    PiecePreviewView(label: "Hold", piece: TetrisPiece(position: CGPoint(x: 10 / 2 - 1, y: 0), color: .purple, rotations: [[[false, true, false], [true, true, true]],[[true, false], [true, true], [true, false]],[[true, true, true], [false, true, false]],[[false, true], [true, true], [false, true]]
    ]))
}

#Preview("Piece Preview Next") {
    PiecePreviewView(label: "Next", piece: TetrisPiece(position: CGPoint(x: 10 / 2 - 1, y: 0), color: .yellow, rotations: [[[true, true], [true, true]]]))
}
