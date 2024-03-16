//
//  KeyboardCommandsResponder.swift
//  Tetris
//
//  Created by David Solis on 3/15/24.
//

import UIKit

class KeyboardInputViewController: UIViewController {
    var moveLeftAction: (() -> Void)?
    var moveRightAction: (() -> Void)?
    var rotateAction: (() -> Void)?
    var dropAction: (() -> Void)?
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(action: #selector(moveLeft), input: UIKeyCommand.inputLeftArrow),
            UIKeyCommand(action: #selector(moveRight), input: UIKeyCommand.inputRightArrow),
            UIKeyCommand(action: #selector(rotate), input: UIKeyCommand.inputUpArrow),
            UIKeyCommand(action: #selector(drop), input: UIKeyCommand.inputDownArrow)
        ]
    }
    
    @objc func moveLeft() {
        moveLeftAction?()
    }
    
    @objc func moveRight() {
        moveRightAction?()
    }
    
    @objc func rotate() {
        rotateAction?()
    }
    
    @objc func drop() {
        dropAction?()
    }
}
