//
//  GameControllerManager.swift
//  Tetris
//
//  Created by David Solis on 3/21/24.
//

@preconcurrency import GameController

@MainActor
class GameControllerManager {
    weak var gameManager: GameManager?
    private var movementDirection: Direction?
    private var movementTask: Task<Void, Never>?
    private var connectionTask: Task<Void, Never>?

    init(gameManager: GameManager) {
        self.gameManager = gameManager
        setupControllers()
    }

    deinit {
        connectionTask?.cancel()
        movementTask?.cancel()
    }

    private func setupControllers() {
        connectionTask = Task {
            for await notification in NotificationCenter.default.notifications(named: .GCControllerDidConnect) {
                guard !Task.isCancelled else { return }
                if let controller = notification.object as? GCController {
                    configure(controller: controller)
                }
            }
        }

        for controller in GCController.controllers() {
            configure(controller: controller)
        }
    }

    private func configure(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { [weak self] gamepad, _ in
            let menuPressed = gamepad.buttonMenu.isPressed
            let bPressed = gamepad.buttonB.isPressed
            let xPressed = gamepad.buttonX.isPressed
            let xAxis = gamepad.leftThumbstick.xAxis.value
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.processInput(menuPressed: menuPressed, bPressed: bPressed, xPressed: xPressed, xAxis: xAxis)
            }
        }
    }

    private func processInput(menuPressed: Bool, bPressed: Bool, xPressed: Bool, xAxis: Float) {
        if menuPressed {
            if gameManager?.state == .playing {
                gameManager?.handleAction(.pause)
            } else if gameManager?.state == .paused {
                gameManager?.handleAction(.resume)
            }
        }
        if bPressed {
            gameManager?.handleAction(.rotate)
        }
        if xPressed {
            gameManager?.handleAction(.hold)
        }

        if xAxis < -0.5 {
            startMoving(.left)
        } else if xAxis > 0.5 {
            startMoving(.right)
        } else {
            stopMoving()
        }
    }

    private func startMoving(_ direction: Direction) {
        movementDirection = direction
        movementTask?.cancel()
        let action: PlayerAction = direction == .left ? .moveLeft : .moveRight
        gameManager?.handleAction(action)
        movementTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                switch movementDirection {
                    case .left:
                        gameManager?.handleAction(.moveLeft)
                    case .right:
                        gameManager?.handleAction(.moveRight)
                    case .none:
                        break
                }
            }
        }
    }

    private func stopMoving() {
        movementTask?.cancel()
        movementTask = nil
        movementDirection = nil
    }
}
