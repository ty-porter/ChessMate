# frozen_string_literal: true

require 'helpers/notation_parser'
require 'chessmate'
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
    origin = encode_origin
    capture = @board[@dest_y][@dest_x] || @en_passant ? 'x' : ''
    destination = NotationParser.encode_notation(@dest)

    origin + capture + destination
  end

  private

  def encode_origin
    notation_required = [false, false]
    game = ChessMate.new(board: @board)
    encoded_dest = NotationParser.encode_notation(@dest)

    @board.each_with_index do |row, y|
      row.each_with_index do |col, x|
        next unless @piece == col && [@orig_y, @orig_x] != [y, x]

        encoded_orig = NotationParser.encode_notation([y, x])

        if game.move(encoded_orig, encoded_dest, true)
          notation_required[0] = true if @orig_y == y || (@orig_y != y && @orig_x != x)
          notation_required[1] = true if @orig_x == x
        end
      end
    end

    if notation_required.nil? || notation_required.none?(true)
      if @piece_type == 'P'
        return NotationParser.encode_notation(@orig)[0] if @board[@dest_y][@dest_x] || @en_passant

        return ''
      end
      return @piece_type
    end
    ambiguous_encoded = @piece_type
    encoded_origin_chars = NotationParser.encode_notation(@orig).chars
    notation_required.each_with_index do |value, i|
      ambiguous_encoded += encoded_origin_chars[i] if value
    end
    ambiguous_encoded
  end
end
