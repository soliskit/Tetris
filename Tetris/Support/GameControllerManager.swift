//
//  GameControllerManager.swift
//  Tetris
//
//  Created by David Solis on 3/21/24.
//

import GameController

class GameControllerManager {
    weak var gameManager: GameManager?
    private var movementDirection: Direction?
    private var movementTimer: Timer?
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        setupControllers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopMoving()
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
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, _) in
            self?.handeButtonInput(gamepad: gamepad)
        }
    }
    
    private func handeButtonInput(gamepad: GCExtendedGamepad) {
        if gameManager?.state == .playing && gamepad.buttonMenu.isPressed {
            gameManager?.handleAction(.pause)
        }
        if gameManager?.state == .paused && gamepad.buttonMenu.isPressed {
            gameManager?.handleAction(.resume)
        }
        if gamepad.buttonB.isPressed {
            gameManager?.handleAction(.rotate)
        }
        if gamepad.buttonX.isPressed {
            gameManager?.handleAction(.hold)
        }
    }
    
    private func handleJoystickInput(gamepad: GCExtendedGamepad) {
        let xValue = gamepad.leftThumbstick.xAxis.value
        
        if xValue < -0.5 {
            startMoving(.left)
        } else if xValue > 0.5 {
            startMoving(.right)
        } else {
            stopMoving()
        }
    }
    
    private func startMoving(_ direction: Direction) {
        movementDirection = direction
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            switch self.movementDirection {
                case .left:
                    self.gameManager?.handleAction(.moveLeft)
                case .right:
                    self.gameManager?.handleAction(.moveRight)
                case .none:
                    break
            }
        }
    }
    
    private func stopMoving() {
        movementTimer?.invalidate()
        movementTimer = nil
        movementDirection = nil
    }
}
