require_relative './piece'

class Knight < Piece
	
	def self.move_is_valid?(orig, dest)
		x_offset = (orig[0] - dest[0]).abs
		y_offset = (orig[1] - dest[1]).abs

		(x_offset == 2 && y_offset == 1) || (x_offset == 1 && y_offset == 2)
	end
	
end