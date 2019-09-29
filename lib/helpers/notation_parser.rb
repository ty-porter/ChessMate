module NotationParser
	def self.parse_notation(square)
		col = square[0].downcase().ord - 97 
		row = 7 - ( square[1].to_i - 1 )

		if col >= 0 && col < 8 && row >= 0 && row < 8
			[row,col]
		else
			return nil
		end
	end

	def self.encode_notation(coords)
		row, col = coords

		if col >= 0 && col < 8 && row >= 0 && row < 8
			col = (col + 97).chr
			row = (8 - row).to_s
			return col + row
		else
			return nil
		end
	end
end