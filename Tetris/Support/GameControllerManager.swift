//
//  GameControllerManager.swift
//  Tetris
//
//  Created by David Solis on 3/21/24.
//

import GameController

class GameControllerManager {
    weak var gameManager: GameManager?
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        setupControllers()
    }
    
    private func setupControllers() {
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidConnect), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidDisconnect), name: .GCControllerDidDisconnect, object: nil)
        
        GCController.controllers().forEach { controller in
            configure(controller: controller)
        }
    }
    
    @objc func controllerDidConnect(notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        configure(controller: controller)
    }
    
    @objc func controllerDidDisconnect(notification: Notification) {
        
    }
    
    private func configure(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, element) in
            self?.handleInput(gamepad: gamepad, element: element)
        }
    }
    
    private func handleInput(gamepad: GCExtendedGamepad, element: GCControllerElement) {
        
        if gamepad.dpad.left.isPressed {
            gameManager?.handleAction(.moveLeft)
        } else if gamepad.dpad.right.isPressed {
            gameManager?.handleAction(.moveRight)
        } else if gamepad.dpad.up.isPressed {
            gameManager?.handleAction(.rotate)
        } else if gamepad.dpad.down.isPressed {
            gameManager?.handleAction(.drop)
        }
        
        if gamepad.buttonA.isPressed {
            gameManager?.handleAction(.hold)
        }
    }
}

