# frozen_string_literal: true

require 'pieces/piece'

class Pawn < Piece
  def self.move_is_valid?(orig, dest, board, en_passant)
    return true if en_passant(orig, dest, board, en_passant)

    orig_y = orig[0]
    orig_x = orig[1]
    dest_y = dest[0]
    dest_x = dest[1]
    piece_type = board[orig_y][orig_x]
    piece_color = piece_type[0].downcase

    if piece_color == 'w'
      direction = 1
    elsif piece_color == 'b'
      direction = -1
    else
      return false
    end

    if capturable?(orig, dest, board) &&
       (orig_x - dest_x).abs == 1 &&
       (orig_y - dest_y) * direction == 1
      return true
    end

    not_obstructed = !obstructed?(orig, dest, board) && !dest_occupied?(dest, board)

    basic_move = ((orig_y - dest_y) * direction == 1 && orig_x == dest_x)
    move_double_on_first_turn = (orig_y - dest_y == (2 * direction)) && (orig_x == dest_x)

    not_obstructed && (move_double_on_first_turn || basic_move)
  end

  def self.en_passant(orig, dest, board, en_passant)
    orig_y = orig[0]
    orig_x = orig[1]
    dest_y = dest[0]
    dest_x = dest[1]
    piece_type = board[orig_y][orig_x]
    opposite_color = piece_type[0].downcase == 'w' ? :black : :white
    direction = opposite_color == :white ? -1 : 1

    return false if en_passant[opposite_color].nil?

    if en_passant[opposite_color] == [dest[0] + direction, dest[1]]
      if (orig_x - dest_x).abs == 1 &&
         (orig_y - dest_y) * direction == 1
        return true
      end
    end
    false
  end

  def self.dest_occupied?(dest, board)
    dest_y = dest[0]
    dest_x = dest[1]
    !board[dest_y][dest_x].nil?
  end
end
