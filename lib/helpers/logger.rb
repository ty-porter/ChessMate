# frozen_string_literal: true

require 'helpers/notation_parser'
require 'pry'

class Logger
  def initialize(orig, dest, board, en_passant = false)
    @orig = orig
    @dest = dest
    @board = board
    @en_passant = en_passant

    @orig_y, @orig_x = @orig
    @dest_y, @dest_x = @dest

    @piece = @board[@orig_y][@orig_x]

    @piece_color, @piece_type = @piece.chars
  end

  def log_move
    if @board[@dest_y][@dest_x] || @en_passant
      log_capture
    else
      log_normal_move
    end
  end

  private

  def log_normal_move
    notation = NotationParser.encode_notation(@dest)
    @piece_type != 'P' ? @piece_type + notation : notation
  end

  def log_capture
    origin_square = NotationParser.encode_notation(@orig)[0] if @piece_type == 'P'
    origin_square ||= @piece_type
    destination_square = NotationParser.encode_notation(@dest)
    origin_square + 'x' + destination_square
  end
end
