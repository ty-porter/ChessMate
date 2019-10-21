# frozen_string_literal: true

DEFAULT = {
  board: [
    %w[BR BN BB BQ BK BB BN BR],
    %w[BP BP BP BP BP BP BP BP],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    %w[WP WP WP WP WP WP WP WP],
    %w[WR WN WB WQ WK WB WN WR]
  ],
  turn: 1,
  promotable: nil,
  en_passant: { white: nil, black: nil },
  in_check: { white: false, black: false },
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
}.freeze
