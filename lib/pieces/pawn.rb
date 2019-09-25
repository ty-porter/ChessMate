require_relative './piece'

class Pawn < Piece
	
	def self.move_is_valid?(orig, dest)
		if (orig[0] - dest[0]).abs == 1 && orig[1] == dest[1]
			return true
		else
			return false
		end
	end
	
end