module NotationParser
	def self.parse_notation(square)
		col = square[0].downcase().ord - 97 
		row = 7 - ( square[1].to_i - 1 )

		# Check if within the bounds of the board
		if col >= 0 && col < 8 && row >= 0 && row < 8
			[row,col]
		else
			return nil
		end
	end
end