require 'pieces/piece'

class King < Piece
	def self.move_is_valid?(orig, dest, board)
		(orig[0] - dest[0]).abs <= 1 && (orig[1] - dest[1]).abs <= 1 &&
		( !self.destination_occupied?(dest, board) || self.is_capturable?(orig, dest, board) )
	end
	
end