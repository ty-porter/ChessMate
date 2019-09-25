require_relative './piece'

class King < Piece
	
	def self.move_is_valid?(orig, dest)
		(orig[0] - dest[0]).abs <= 1 && (orig[1] - dest[1]).abs <= 1 
	end
	
end