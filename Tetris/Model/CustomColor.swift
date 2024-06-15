//
//  CustomColor.swift
//  Tetris
//
//  Created by David Solis on 3/24/24.
//

import SwiftUI

struct CustomColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    var value: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(from color: Color) {
        let uiColor = UIColor(color)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
}
