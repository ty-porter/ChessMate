require_relative './piece'

class Bishop < Piece
	
	def self.move_is_valid?(orig, dest)
		(orig[0] - dest[0]).abs == (orig[1] - dest[1]).abs 
	end
	
end