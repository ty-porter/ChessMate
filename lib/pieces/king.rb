# frozen_string_literal: true

require 'pieces/piece'

class King < Piece
  def self.move_is_valid?(orig, dest, board, castling)
    valid_castling_move = valid_castling_move?(orig,dest,board,castling) if (orig[1] - dest[1]).abs == 2

    valid_castling_move || (
    (orig[0] - dest[0]).abs <= 1 && (orig[1] - dest[1]).abs <= 1 &&
      (!destination_occupied?(dest, board) || capturable?(orig, dest, board))
    )
  end

  def self.valid_castling_move?(orig,dest,board,castling)
    true
  end
end
