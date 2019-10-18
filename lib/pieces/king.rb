# frozen_string_literal: true

require 'pieces/piece'
require 'chessmate'

class King < Piece
  def self.move_is_valid?(orig, dest, board, castling)
    valid_castling_move = valid_castling_move?(orig,dest,board,castling) if (orig[1] - dest[1]).abs == 2

    valid_castling_move || (
    (orig[0] - dest[0]).abs <= 1 && (orig[1] - dest[1]).abs <= 1 &&
      (!destination_occupied?(dest, board) || capturable?(orig, dest, board))
    )
  end

  def self.valid_castling_move?(orig,dest,board,castling)
    orig_y = orig[0]
    orig_x = orig[1]
    dest_y = dest[0]
    dest_x = dest[1]

    return false if orig_y != dest_y || (orig_x - dest_x).abs != 2
    
    king = board[orig_y][orig_x]
    king_color = king[0] == 'W' ? :white : :black
    king_type = king[1]
    castle_direction = orig_x < dest_x ? :kingside : :queenside

    return false if castling[king_color][castle_direction] == false

    test_board = board.map(&:dup)
    return false if ChessMate.new(test_board).in_check?(test_board)[king_color]

    test_range = castle_direction == :kingside ? [5,6] : [1,2,3]
    test_range.each do |x|
      return false if board[orig_y][x]
      test_board = board.map(&:dup)
      test_board[orig_y][x] = "WK"
      test_board[orig_y][orig_x] = nil
      test = ChessMate.new(test_board)
      return false if test.in_check?(test_board)[king_color] && x != 1
    end
    true
  end
end
