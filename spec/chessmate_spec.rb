require 'spec_helper'
require_relative '../lib/chessmate'
require_relative '../lib/helpers/notation_parser'

describe ChessMate do


    describe "board method" do
        before :each do
            @chess = ChessMate.new
        end

        it "should return the board state" do
            expect(@chess.board).to match_array(
                [
                ['BR', 'BN', 'BN', 'BQ', 'BK', 'BB', 'BN', 'BR'],
                ['BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                ['WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP'],
                ['WR', 'WN', 'WB', 'WQ', 'WK', 'WB', 'WN', 'WR']
                ]
            )
        end
    end

    describe "update method" do
        before :each do
            @chess = ChessMate.new
        end
        
        it "should update the board after moving" do
            @chess.update([6,0], [5,0])
            expect(@chess.board).to match_array(
                [
                ['BR', 'BN', 'BN', 'BQ', 'BK', 'BB', 'BN', 'BR'],
                ['BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                ['WP', nil, nil, nil, nil, nil, nil, nil],
                [nil, 'WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP'],
                ['WR', 'WN', 'WB', 'WQ', 'WK', 'WB', 'WN', 'WR']
                ]
            )
        end
    end

    describe "move method" do
        before :each do
            @chess = ChessMate.new
        end

        it "should successfully parse the chess notation and move the piece" do
            @chess.move('c2', 'c3')
            expect(@chess.board).to match_array(
                [
                ['BR', 'BN', 'BN', 'BQ', 'BK', 'BB', 'BN', 'BR'],
                ['BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, 'WP', nil, nil, nil, nil, nil],
                ['WP', 'WP', nil, 'WP', 'WP', 'WP', 'WP', 'WP'],
                ['WR', 'WN', 'WB', 'WQ', 'WK', 'WB', 'WN', 'WR']
                ]
            )
        end
    end
end