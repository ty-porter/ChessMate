# frozen_string_literal: true

require 'pieces/piece'

class Bishop < Piece
  def self.move_is_valid?(orig, dest, board)
    not_obstructed = !obstructed?(orig, dest, board)

    not_obstructed &&
      (!destination_occupied?(dest, board) || capturable?(orig, dest, board)) &&
      (orig[0] - dest[0]).abs == (orig[1] - dest[1]).abs
  end
end
