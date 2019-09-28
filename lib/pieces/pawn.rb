require 'pieces/piece'

class Pawn < Piece
	def self.move_is_valid?(orig, dest, board)
		orig_y = orig[0]
		orig_x = orig[1]
		dest_y = dest[0]
		dest_x = dest[1]
		piece_type = board[orig_y][orig_x]
		piece_color = piece_type[0].downcase()

		if piece_color == "w"
			direction = 1
		elsif piece_color == "b"
			direction = -1
		else
			return false
		end

		if self.is_capturable?(orig,dest,board) && 
			 (orig_x - dest_x).abs == 1 && 
			 (orig_y - dest_y) * direction == 1
			return true
		end

		not_obstructed = !self.is_obstructed?(orig, dest, board)
	
		basic_move = ( (orig_y - dest_y) * direction == 1 && orig_x == dest_x )
		move_double_on_first_turn = ( orig_y - dest_y == (2 * direction) ) && ( orig_x == dest_x )

		move_double_on_first_turn && not_obstructed || basic_move
	end
	
end