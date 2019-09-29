class ChessMate
	require 'helpers/notation_parser'
	require 'pieces/pawn'
	require 'pieces/rook'
	require 'pieces/bishop'
	require 'pieces/knight'
	require 'pieces/queen'
	require 'pieces/king'
	
	attr_reader :board, :turn, :in_check

	def initialize(board=nil,turn=nil)
		if board.nil?
			@board = 
					[
					['BR', 'BN', 'BN', 'BQ', 'BK', 'BB', 'BN', 'BR'],
					['BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
					[nil, nil, nil, nil, nil, nil, nil, nil],
					[nil, nil, nil, nil, nil, nil, nil, nil],
					[nil, nil, nil, nil, nil, nil, nil, nil],
					[nil, nil, nil, nil, nil, nil, nil, nil],
					['WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP'],
					['WR', 'WN', 'WB', 'WQ', 'WK', 'WB', 'WN', 'WR']
					]
		else
			@board = board
		end

		if turn.nil?
			@turn = 1
		else
			@turn = turn
		end

		@in_check = {
			"white": false,
			"black": false
		}
	end	

	def update(orig, dest=nil)
		orig_y = orig[0]
		orig_x = orig[1]
		dest_y = dest[0]
		dest_x = dest[1]
		piece_type = @board[orig_y][orig_x]
		@board[orig_y][orig_x] = nil
		@board[dest_y][dest_x] = piece_type
		@turn += 1
	end

	def in_check?(board=nil)
		board = board.nil? ? @board : board
		wk_coords = bk_coords = nil

		board.each_with_index do |row, y|
			if row.include?("WK") 
				wk_coords = [y, row.index("WK")]
			end
			if row.include?("BK") 
				bk_coords = [y, row.index("BK")]
			end
		end

		if wk_coords.nil? || bk_coords.nil?
			return { "white": false, "black": false }
		end

		wk_pos = NotationParser.encode_notation(wk_coords)
		bk_pos = NotationParser.encode_notation(bk_coords)

		white_in_check = black_in_check = false
		board.each_with_index do |row, y|
			row.each_with_index do |col, x|
				if !col.nil?
					piece_pos = NotationParser.encode_notation([y,x])
					if col[0] == "W"
						if move(piece_pos, bk_pos, true)
							black_in_check = true
						end
					elsif col[0] == "B"
						if move(piece_pos, wk_pos, true)
							white_in_check = true
						end
					end
				end
			end
		end

		{ "white": white_in_check, "black": black_in_check }
		
	end

	def move(orig, dest, test=false)
		orig_pos = NotationParser.parse_notation(orig)
		dest_pos = NotationParser.parse_notation(dest)

		# Return false for malformed postition input
		if orig_pos.nil? || dest_pos.nil?
			return false
		end

		# Get the piece type from the board 
		orig_y = orig_pos[0]
		orig_x = orig_pos[1]

		piece = @board[orig_y][orig_x]
		piece_type = piece[1]

		if piece[0].downcase() == "w"
			piece_color = :white
		elsif piece[0].downcase() == "b"
			piece_color = :black
		else
			piece_color = nil
		end

		# Check valid move depending on piece
		# TODO: Add more pieces!
		valid_move = nil
		case piece_type
		when "P"
			valid_move = Pawn.move_is_valid?(orig_pos,dest_pos,@board)
		when "R"
			valid_move = Rook.move_is_valid?(orig_pos,dest_pos,@board)
		when "B"
			valid_move = Bishop.move_is_valid?(orig_pos,dest_pos,@board)
		when "N"
			valid_move = Knight.move_is_valid?(orig_pos,dest_pos,@board)
		when "Q"
			valid_move = Queen.move_is_valid?(orig_pos,dest_pos,@board)
		when "K"
			valid_move = King.move_is_valid?(orig_pos,dest_pos,@board)
		else
			valid_move = false
		end

		if !test
			@in_check = self.in_check?
		end

		if valid_move && !test && !@in_check[piece_color]
			self.update(orig_pos, dest_pos)
		end 

		valid_move && !@in_check[piece_color]

	end
end