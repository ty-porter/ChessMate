class Game
	require 'helpers/notation_parser'
	attr_accessor :board

	def initialize(board=nil,turn=nil)
		if board.nil?
			@board = [
							['BR', 'BN', 'BN', 'BQ', 'BK', 'BB', 'BN', 'BR'],
							['BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
							[nil, nil, nil, nil, nil, nil, nil, nil],
							[nil, nil, nil, nil, nil, nil, nil, nil],
							[nil, nil, nil, nil, nil, nil, nil, nil],
							[nil, nil, nil, nil, nil, nil, nil, nil],
							['WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP'],
							['WR', 'WN', 'WB', 'WQ', 'WK', 'WB', 'WN', 'WR']
							];
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

	def move(orig, dest=nil)
		pos = NotationParser.parse_notation(orig)

		puts pos
	end
end