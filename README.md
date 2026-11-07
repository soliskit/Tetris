# Tetris

Tetris for iPhone and Mac, built with SwiftUI.

Play with touch, the keyboard, or a game controller. Clear lines, hold
a piece for later, and keep your best score on the device.

## Run the project

Requires Xcode 26 or newer; the app targets iOS 26 and macOS 26.

1. Clone this repository and open `Tetris.xcodeproj` in Xcode.
2. Select the **Tetris** scheme and an iPhone simulator or device, or
   My Mac.
3. Run with Cmd-R. Run the tests with Cmd-U.

## Features

- 10 by 20 board with a ghost piece showing where the current piece
  will land
- Wall kicks, so rotations still fit near walls and other blocks
- Hold a piece once per drop, and a preview of the next three pieces
- Scoring of 100, 300, 500 and 800 points for 1 to 4 lines
- Level rises every 1000 points, speeding up gravity from 0.7 toward
  0.25 seconds per row
- Lock delay of 0.5 seconds once a piece comes to rest, reset by moving
  the piece, up to 15 times
- High score and the current game are saved on the device, so a paused
  game can continue later

## Controls

- Touch: drag on the board to move the piece; on-screen buttons for the
  game controls
- Keyboard: A and D move, W rotates, S drops, H holds
- Game controller: any controller that offers Apple's standard
  extended-gamepad profile (dual sticks and the usual buttons), through
  the GameController framework

## Project structure

- `Tetris/` - the app: `GameManager.swift` runs the game, `Model/`
  holds the board, pieces and saved session, `View/` the SwiftUI views,
  and `Support/` input and helpers
- `TetrisTests/` - the test suite
- `.github/workflows/test.yml` - CI, below

## Tests

The suite uses Swift Testing and covers the game engine, the piece
model and rotation, and the piece factory. Run it in Xcode with Cmd-U.
CI builds and runs the same suite on an iPhone simulator for every push
to main and every pull request.

## License

[MIT](LICENSE.md)
