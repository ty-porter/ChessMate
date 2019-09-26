class Piece
	def self.is_obstructed?(orig, dest, board)
		orig_y = orig[0]
		orig_x = orig[1]
		dest_y = dest[0]
		dest_x = dest[1]

		if orig_y == dest_y

			direction = orig_x > dest_x ? 1 : -1
			( (orig_x - dest_x).abs - 1 ).times do |x|
				test_pos = orig_x - (x * direction) - direction
				if !board[orig_y][test_pos].nil?
					return true
				end
			end
			return false

		elsif orig_x == dest_x

			direction = orig_y > dest_y ? 1 : -1
			( (orig_y - dest_y).abs - 1 ).times do |y|
				test_pos = orig_y - (y * direction) - direction
				if !board[test_pos][orig_x].nil?
					return true
				end
			end

			return false

		elsif (orig_y - dest_y).abs == (orig_x - dest_x).abs
			
			x_direction = orig_x > dest_x ? 1 : -1
			y_direction = orig_y > dest_y ? 1 : -1

			( (orig_y - dest_y).abs - 1 ).times do |v|
				test_y_pos = orig_y - (v * y_direction) - y_direction
				test_x_pos = orig_x - (v * x_direction) - x_direction
				if !board[test_y_pos][test_x_pos].nil?
					return true
				end
			end

			return false

		else
			return nil
		end
	end
end