require 'spec_helper'
require_relative '../lib/pieces/piece'

describe Piece do
	describe "is_obstructed? method" do
		it "should return false if not obstructed vertically" do
			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[0,3],board)).to eql(false)
		end

		it "should return false if not obstructed horizontally" do
			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[7,7],board)).to eql(false)
		end

		it "should return false if not obstructed diagonally" do
			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[4,0],board)).to eql(false)
		end

		it "should return true if obstructed vertically" do
			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			board[6][3] = "WP"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[0,3],board)).to eql(true)
		end

		it "should return true if obstructed horizontally" do
			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			board[7][4] = "WK"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[7,7],board)).to eql(true)
		end

		it "should return true if obstructed diagonally" do
			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			board[5][1] = "WP"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[4,0],board)).to eql(true)
		end

		it "should ignore the origin and end positions" do
			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			board[7][7] = "WR"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[7,7],board)).to eql(false)

			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			board[0][3] = "BQ"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[0,3],board)).to eql(false)

			board = Array.new(8) { Array.new(8,nil) }
			board[7][3] = "WQ"
			board[4][0] = "WP"
			piece = Piece.new
			expect(piece.class.is_obstructed?([7,3],[4,0],board)).to eql(false)
		end
	end
end