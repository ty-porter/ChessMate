class ChessMate
	require 'helpers/notation_parser'
	attr_accessor :board

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
	end	

	def board
		@board
	end

	def update(orig, dest=nil)
		orig_y = orig[0]
		orig_x = orig[1]
		dest_y = dest[0]
		dest_x = dest[1]
		piece_type = @board[orig_y][orig_x]
		@board[orig_y][orig_x] = nil
		@board[dest_y][dest_x] = piece_type
	end

	def move(orig, dest)
		orig_pos = NotationParser.parse_notation(orig)
		dest_pos = NotationParser.parse_notation(dest)

		self.update(orig_pos, dest_pos)
	end
end