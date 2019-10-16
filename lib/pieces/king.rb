# frozen_string_literal: true

require 'pieces/piece'

class King < Piece
  def self.move_is_valid?(orig, dest, board)
    (orig[0] - dest[0]).abs <= 1 && (orig[1] - dest[1]).abs <= 1 &&
      (!destination_occupied?(dest, board) || capturable?(orig, dest, board))
  end
end
