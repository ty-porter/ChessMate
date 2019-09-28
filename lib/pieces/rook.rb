require 'pieces/piece'

class Rook < Piece
	def self.move_is_valid?(orig, dest, board)

		not_obstructed = !self.is_obstructed?(orig, dest, board)

		not_obstructed && 
		( !self.destination_occupied?(dest, board) || self.is_capturable?(orig, dest, board) ) &&
		(
			orig[0] == dest[0] || orig[1] == dest[1]
		)
		
	end
	
end