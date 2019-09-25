require_relative './piece'

class Rook < Piece
	
	def self.move_is_valid?(orig, dest)
		orig[0] == dest[0] || orig[1] == dest[1]
	end
	
end