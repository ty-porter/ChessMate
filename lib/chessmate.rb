# frozen_string_literal: true

require 'deep_dup'

class ChessMate
  require 'helpers/notation_parser'
  require 'pieces/pawn'
  require 'pieces/rook'
  require 'pieces/bishop'
  require 'pieces/knight'
  require 'pieces/queen'
  require 'pieces/king'
  require 'helpers/default'
  require 'helpers/logger'

  attr_reader :board,
              :turn,
              :in_check,
              :promotable,
              :en_passant,
              :castling,
              :allow_out_of_turn,
              :move_history

  def initialize(board: nil,
                 turn: nil,
                 promotable: nil,
                 en_passant: nil,
                 castling: nil,
                 in_check: nil,
                 allow_out_of_turn: nil,
                 move_history: nil)
    @board = board || DEFAULT[:board].map(&:dup)
    @turn = turn || DEFAULT[:turn]
    @promotable = promotable || DeepDup.deep_dup(DEFAULT[:promotable])
    @en_passant = en_passant || DeepDup.deep_dup(DEFAULT[:en_passant])
    @castling = castling || DeepDup.deep_dup(DEFAULT[:castling])
    @in_check = in_check || DeepDup.deep_dup(DEFAULT[:in_check])

    @allow_out_of_turn = if allow_out_of_turn.nil?
                           ENV['TEST'] == 'true' || false
                         elsif [true, false].include?(allow_out_of_turn)
                           allow_out_of_turn
                         else
                           false
                         end
    @move_history = move_history || []
  end

  def update(orig, dest = nil)
    orig_y, orig_x = orig
    dest_y, dest_x = dest
    piece_type = @board[orig_y][orig_x]
    piece_color = piece_type[0] == 'W' ? :white : :black
    opposite_color = piece_type[0] == 'W' ? :black : :white
    direction = opposite_color == :white ? -1 : 1

    @en_passant[piece_color] = nil if @en_passant[piece_color]

    case piece_type[1]
    when 'P'
      @en_passant[piece_color] = dest if (orig_y - dest_y).abs > 1
      if @en_passant[opposite_color] == [dest_y + direction, dest_x]
        en_passant = true
        en_passant_coords = @en_passant[opposite_color]
      end
    when 'K'
      @castling[piece_color].keys.each do |side|
        @castling[piece_color][side] = false
      end
      if (orig_x - dest_x).abs == 2
        castle = true
        old_rook_x_position = orig_x < dest_x ? 7 : 0
        new_rook_x_position = orig_x < dest_x ? 5 : 3
      end
    when 'R'
      if [0, 7].include?(orig_x)
        direction = orig_x == 7 ? :kingside : :queenside
        @castling[piece_color][direction] = false
      end
    end

    @board[en_passant_coords[0]][en_passant_coords[1]] = nil if en_passant

    if castle
      @board[orig_y][old_rook_x_position] = nil
      @board[orig_y][new_rook_x_position] = piece_type[0] + 'R'
    end

    logger = Logger.new(orig, dest, @board)
    @move_history << logger.log_move

    @board[orig_y][orig_x] = nil
    @board[dest_y][dest_x] = piece_type

    @promotable = dest if piece_type[1] == 'P' && promote?(dest)
    @in_check = in_check?
    @turn += 1
  end

  def in_check?(board = nil)
    board = board.nil? ? @board : board
    wk_coords = bk_coords = nil

    board.each_with_index do |row, y|
      wk_coords = [y, row.index('WK')] if row.include?('WK')
      bk_coords = [y, row.index('BK')] if row.include?('BK')
    end

    wk_pos = NotationParser.encode_notation(wk_coords) if wk_coords
    bk_pos = NotationParser.encode_notation(bk_coords) if bk_coords

    white_in_check = black_in_check = false
    board.each_with_index do |row, y|
      row.each_with_index do |col, x|
        next if col.nil?

        piece_pos = NotationParser.encode_notation([y, x])
        if col[0] == 'W' && bk_pos
          black_in_check = true if move(piece_pos, bk_pos, test: true)
        elsif col[0] == 'B' && wk_pos
          white_in_check = true if move(piece_pos, wk_pos, test: true)
        end
      end
    end

    { white: white_in_check, black: black_in_check }
  end

  def move(orig, dest, test = false, test_board = nil)
    orig_pos = NotationParser.parse_notation(orig)
    dest_pos = NotationParser.parse_notation(dest)

    return false if orig_pos.nil? || dest_pos.nil?

    orig_y = orig_pos[0]
    orig_x = orig_pos[1]

    piece = @board[orig_y][orig_x]
    piece_type = piece[1]
    allowed_turn = piece[0] == 'W' ? :odd? : :even?

    return false unless @allow_out_of_turn || @turn.send(allowed_turn) || test

    board = test_board.nil? ? @board : test_board
    valid_move = case piece_type
                 when 'P'
                   Pawn.move_is_valid?(orig_pos, dest_pos, board, @en_passant.dup)
                 when 'R'
                   Rook.move_is_valid?(orig_pos, dest_pos, board)
                 when 'B'
                   Bishop.move_is_valid?(orig_pos, dest_pos, board)
                 when 'N'
                   Knight.move_is_valid?(orig_pos, dest_pos, board)
                 when 'Q'
                   Queen.move_is_valid?(orig_pos, dest_pos, board)
                 when 'K'
                   King.move_is_valid?(orig_pos, dest_pos, board, @castling.dup)
                 else
                   false
                 end
    unless test
      in_check_after_move = in_check_after_move?(orig_pos, dest_pos)
      update(orig_pos, dest_pos) if valid_move && !test && !in_check_after_move
    end

    valid_move && !in_check_after_move
  end

  def in_check_after_move?(orig, dest)
    test_board = @board.map(&:dup)

    orig_y, orig_x = orig
    dest_y, dest_x = dest
    piece = test_board[orig_y][orig_x]
    piece_type = test_board[orig_y][orig_x]
    opposite_color = piece_type[0] == 'W' ? :black : :white
    direction = opposite_color == :white ? -1 : 1

    if piece_type[1] == 'P' && @en_passant[opposite_color] == [dest_y + direction, dest_x]
      en_passant = true
      en_passant_coords = [@en_passant[opposite_color][0], @en_passant[opposite_color][1]]
    end

    test_board[en_passant_coords[0]][en_passant_coords[1]] = nil if en_passant

    test_board[orig_y][orig_x] = nil
    test_board[dest_y][dest_x] = piece_type

    piece_color = piece[0]
    king = piece_color + 'K'

    king_coords = nil
    test_board.each_with_index do |row, y|
      king_coords = [y, row.index(king)] if row.include?(king)
    end

    return false if king_coords.nil?

    king_pos = NotationParser.encode_notation(king_coords)

    test_board.each_with_index do |row, y|
      row.each_with_index do |col, x|
        next unless !col.nil? && col[0] != piece_color

        piece_pos = NotationParser.encode_notation([y, x])
        return true if move(piece_pos, king_pos, true, test_board)
      end
    end

    false
  end

  def any_valid_moves?(color)
    test_board = @board.map(&:dup)

    test_board.each_with_index do |row, orig_y|
      row.each_with_index do |col, orig_x|
        next unless !col.nil? && col[0] == color

        orig_pos = NotationParser.encode_notation([orig_y, orig_x])
        8.times do |dest_x|
          8.times do |dest_y|
            dest_pos = NotationParser.encode_notation([dest_y, dest_x])
            next unless move(orig_pos, dest_pos, true)
            return true unless in_check_after_move?([orig_y, orig_x], [dest_y, dest_x])
          end
        end
      end
    end

    false
  end

  def checkmate?(color)
    piece_color = color.downcase == 'w' ? :white : :black
    !any_valid_moves?(color) && in_check?[piece_color]
  end

  def draw?(color)
    piece_color = color.downcase == 'w' ? :white : :black
    !any_valid_moves?(color) && in_check?[piece_color] == false
  end

  def promote?(square)
    square_y = square[0]
    square_x = square[1]
    piece = @board[square_y][square_x][0]
    promote_column = piece.downcase == 'w' ? 0 : 7
    promote_column == square_y
  end

  def promote!(square, piece)
    square_y = square[0]
    square_x = square[1]

    old_piece = @board[square_y][square_x]
    return nil if old_piece.nil? || !promote?(square)

    case piece.downcase
    when 'rook'
      piece_type = 'R'
    when 'knight'
      piece_type = 'N'
    when 'bishop'
      piece_type = 'B'
    when 'queen'
      piece_type = 'Q'
    else
      return nil
    end

    @board[square_y][square_x] = old_piece[0] + piece_type
  end
end
