//
//  GameControllerManager.swift
//  Tetris
//
//  Created by David Solis on 3/21/24.
//

import GameController

@MainActor
final class GameControllerManager {
    weak var gameManager: GameManager?
    private var movementDirection: Direction?
    private var movementTimer: Timer?
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        setupControllers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async {
            self.stopMoving()
        }
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
        // Handle disconnection if needed
    }
    
    private func configure(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, _) in
            Task { [weak self] in
                guard let self = self else { return }
                await self.handleButtonInput(gamepad: gamepad)
                await self.handleJoystickInput(gamepad: gamepad)
            }
        }
    }
    
    private func handleButtonInput(gamepad: GCExtendedGamepad) async {
        if gamepad.leftTrigger.isPressed {
            await gameManager?.handleAction(.pause)
        }
        if gamepad.rightTrigger.isPressed {
            await gameManager?.handleAction(.resume)
        }
        if gamepad.buttonX.isPressed {
            await gameManager?.handleAction(.hold)
        }
        if gamepad.buttonA.isPressed {
            await gameManager?.handleAction(.rotate)
        }
    }
    
    private func handleJoystickInput(gamepad: GCExtendedGamepad) async {
        let xValue = gamepad.leftThumbstick.xAxis.value
        let yValue = gamepad.leftThumbstick.yAxis.value
        
        if yValue < -0.5 {
            await startMoving(.down)
        } else if xValue < -0.5 {
            await startMoving(.left)
        } else if xValue > 0.5 {
            await startMoving(.right)
        } else {
            DispatchQueue.main.async {
                self.stopMoving()
            }
        }
    }
    
    private func startMoving(_ direction: Direction) async {
        movementDirection = direction
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { [weak self] in
                guard let self = self else { return }
                await self.performMovement()
            }
        }
    }
    
    private func performMovement() async {
        switch movementDirection {
        case .left:
            await gameManager?.handleAction(.moveLeft)
        case .right:
            await gameManager?.handleAction(.moveRight)
        case .down:
            await gameManager?.handleAction(.drop)
        case .none:
            break
        }
    }
    
    private func stopMoving() {
        movementTimer?.invalidate()
        movementTimer = nil
        movementDirection = nil
    }
}
