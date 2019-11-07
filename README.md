<p align="center">
  <img width="800" height="150" src="https://imgur.com/WFCwf9p.png">
</p>
<h2 align="center">A dead-simple chess validation gem for Rails</h2>
<p align="center">
  <a href="https://travis-ci.com/pawptart/ChessMate">
    <img src="https://travis-ci.com/pawptart/ChessMate.svg?branch=master">
  </a>
  <a href="https://github.com/pawptart/ChessMate/issues">
    <img src="https://img.shields.io/github/issues/pawptart/chessmate">
  </a>
  <a href="https://rubygems.org/gems/chessmate">
    <img src="https://img.shields.io/gem/v/chessmate">
  </a>
</p>

## About
ChessMate was built in around 2 months to be as easy to use as possible to quickly and easily bootstrap a chess game in Rails. The original idea came from a bootcamp exercise to build a working chess game, and so the code that was written there has been ported to ChessMate in order to benefit future programmers.

ChessMate is designed to be a backend tool to validate possible chess moves. Therefore, it is intentionally as agnostic to your frontend as possible to integrate into many different frameworks. Because it's designed to be flexible, it even supports custom game boards and can allow out-of-turn movement!

Click [here](http://chessmate-demo.herokuapp.com/) to play with a Rails app running ChessMate! (Or check out the source code [here](https://github.com/pawptart/ChessTest).)

<p align="center">
  <img src="https://i.imgur.com/vyQjL4Y.png">
</p>

## Usage
Simply add ChessMate to your Gemfile:

```
gem 'chessmate'
```

and then you can require it in a model, controller, etc. 

```
require 'chessmate'
```

From there, you are free to utilize all the functions and features of ChessMate!

## Building a new game and playing 

```
game = ChessMate.new
```

Moving pieces works based on chess notation: for example, a common first move is `e2` to `e4`. ChessMate accepts these squares as arguments to the `move` method, so you don't need to specify a piece type like in normal chess notation. To make this move in ChessMate:

```
game.move('e2', 'e4')
```

If a move is invalid, `ChessMate.move` will return `false`, and the board and game state will not update. You also do not need to specify for any "special" moves, like castling or _en passant_, as ChessMate can handle this for you.

Other functions you might call:

```
game.promote?(square)           # Check if a square is capable of pawn promotion
game.promote!(square, piece)     # Promote a promotable pawn, accepts 'rook'/'knight'/'bishop'/'queen'
game.in_check?                  # Determine if either color is currently in check
game.checkmate?(color)          # Determine if the game is over, accepts 'W'/'B'
game.draw?(color)               # Same as checkmate, for draw
```

Using these functions, it's quite simple to build a working chess game!

## Custom games
With ChessMate, it's very easy to build your own custom games. Below is a list of all the defaults ChessMate uses to build a game board, but they can be modified and passed into the `ChessMate.new` method as named arguments in any order, and ChessMate will build a game around your custom params. 

For instance, for a custom board, on turn 10, with the white king in check:

```
custom_board = [
          [nil, nil, nil, nil, 'BK', nil, nil, nil],
          [nil, nil, nil, nil, 'BQ', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          ['WP', nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, 'WK', nil, nil, nil]
        ]
turn = 10
in_check = { white: true, black: false }

game = ChessMate.new(board: custom_board, turn: turn, in_check: in_check)
```

ChessMate can build a game with those parameters!

Here is a list of all the defaults:
```
board: [
  %w[BR BN BB BQ BK BB BN BR],
  %w[BP BP BP BP BP BP BP BP],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  %w[WP WP WP WP WP WP WP WP],
  %w[WR WN WB WQ WK WB WN WR]
]

turn: 1

promotable: nil

en_passant: { white: nil, black: nil }

in_check: { white: false, black: false }

castling: {
  white: {
    kingside: true,
    queenside: true
  },
  black: {
    kingside: true,
    queenside: true
  }
}
```

## Contributing
ChessMate is open to contributions! If you have a feature request, a bug, or a suggestion, please open an issue! Please note that a review is required and passing TravisCI build before your PR can be merged with master.

Currently looking to expand ChessMate features by allowing chess notation logging as well as better documentation!
