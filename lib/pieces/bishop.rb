require 'pieces/piece'

class Bishop < Piece
	def self.move_is_valid?(orig, dest, board)
		not_obstructed = !self.is_obstructed?(orig, dest, board)

		not_obstructed && 
		( !self.destination_occupied?(dest, board) || self.is_capturable?(orig, dest, board) ) &&
		(orig[0] - dest[0]).abs == (orig[1] - dest[1]).abs 
	end
	
end