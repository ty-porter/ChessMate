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
    file = @board.each.map.with_index { |row, i| row[@orig_x] if i != @orig_y }
    rank = @board[@orig_y].map.with_index { |col, i| col if i != @orig_x }

    ambiguous_in_file = file.include?(@piece)
    ambiguous_in_rank = rank.include?(@piece)

    if ambiguous_in_file || ambiguous_in_rank
      notation_required = [false, false]

      game = ChessMate.new(board: @board)
      encoded_dest = NotationParser.encode_notation(@dest)

      if ambiguous_in_file
        file_ambigs = file.map.with_index { |row, i| i if row == @piece }.compact

        file_ambigs.each do |y|
          encoded_orig = NotationParser.encode_notation([y, @orig_x])
          notation_required[1] = true if game.move(encoded_orig, encoded_dest, true)
        end
      end

      if ambiguous_in_rank
        rank_ambigs = rank.map.with_index { |col, i| i if col == @piece }.compact

        rank_ambigs.each do |x|
          encoded_orig = NotationParser.encode_notation([@orig_y, x])
          notation_required[0] = true if game.move(encoded_orig, encoded_dest, true)
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
