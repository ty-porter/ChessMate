# frozen_string_literal: true

class Piece
  def self.obstructed?(orig, dest, board)
    orig_y, orig_x = orig
    dest_y, dest_x = dest

    if orig_y == dest_y

      direction = orig_x > dest_x ? 1 : -1
      ((orig_x - dest_x).abs - 1).times do |x|
        test_pos = orig_x - (x * direction) - direction
        return true unless board[orig_y][test_pos].nil?
      end

      false

    elsif orig_x == dest_x

      direction = orig_y > dest_y ? 1 : -1
      ((orig_y - dest_y).abs - 1).times do |y|
        test_pos = orig_y - (y * direction) - direction
        return true unless board[test_pos][orig_x].nil?
      end

      false

    elsif (orig_y - dest_y).abs == (orig_x - dest_x).abs

      x_direction = orig_x > dest_x ? 1 : -1
      y_direction = orig_y > dest_y ? 1 : -1

      ((orig_y - dest_y).abs - 1).times do |v|
        test_y_pos = orig_y - (v * y_direction) - y_direction
        test_x_pos = orig_x - (v * x_direction) - x_direction
        return true unless board[test_y_pos][test_x_pos].nil?
      end

      false

    end
  end

  def self.capturable?(orig, dest, board)
    orig_y, orig_x = orig
    dest_y, dest_x = dest
    orig_piece = board[orig_y][orig_x]
    dest_piece = board[dest_y][dest_x]

    return false unless orig_piece && dest_piece

    orig_piece_color = orig_piece[0]
    dest_piece_color = dest_piece[0]

    orig_piece_color != dest_piece_color
  end

  def self.destination_occupied?(dest, board)
    dest_y = dest[0]
    dest_x = dest[1]

    !board[dest_y][dest_x].nil?
  end
end
