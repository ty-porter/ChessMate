require 'spec_helper'
require_relative '../lib/chessmate'
require_relative '../lib/helpers/notation_parser'
Dir["../lib/pieces/*.rb"].each {|file| require file}

describe ChessMate do

    describe "board method" do
        before :each do
            @chess = ChessMate.new
        end

        it "should return the board state" do
            expect(@chess.board).to eql(
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
            expect(@chess.board).to eql(
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

        it "should update the turn on a successful update" do
            turn = @chess.turn
            @chess.update([6,0], [5,0])
            expect(@chess.turn).to eql(turn + 1)
        end
    end

    describe "turn method" do
        it "should show the current turn" do
            chess = ChessMate.new
            expect(chess.turn).to eql(1)
        end
    end

    describe "move method" do
        before :each do
            @chess = ChessMate.new
        end

        it "should return false if the move is not within the bounds of the board" do
            expect(@chess.move('z2', 'c3')).to eql(false)
            expect(@chess.board).to eql(
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

        it "should return false if the origin or destination are malformed" do
            expect(@chess.move('22', 'c3')).to eql(false)
            expect(@chess.move('zz', 'c3')).to eql(false)
        end

        it "should generally return false and not update the board if the path is blocked" do
            expect(@chess.move('d1', 'a1')).to eql(false)
            expect(@chess.move('d1', 'd8')).to eql(false)
            expect(@chess.move('d1', 'b3')).to eql(false)
            expect(@chess.board).to eql(
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

        context "for pawns" do
            it "should update the board if pawn move is valid" do
                @chess.move('c2', 'c3')
                expect(@chess.board).to eql(
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

            it "should return false if the pawn move is invalid" do
                expect(@chess.move('c2', 'd3')).to eql(false)
            end

            it "should update the board if pawn's first move is 2 squares" do
                chess = ChessMate.new
                chess.move('c2', 'c4')
                expect(chess.board).to eql(
                    [
                    ['BR', 'BN', 'BN', 'BQ', 'BK', 'BB', 'BN', 'BR'],
                    ['BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, "WP", nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ['WP', 'WP', nil, 'WP', 'WP', 'WP', 'WP', 'WP'],
                    ['WR', 'WN', 'WB', 'WQ', 'WK', 'WB', 'WN', 'WR']
                    ]
                )
                chess = ChessMate.new
                chess.move('b7', 'b5')
                expect(chess.board).to eql(
                    [
                    ['BR', 'BN', 'BN', 'BQ', 'BK', 'BB', 'BN', 'BR'],
                    ['BP', nil, 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, 'BP', nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ['WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP'],
                    ['WR', 'WN', 'WB', 'WQ', 'WK', 'WB', 'WN', 'WR']
                    ]
                )
            end

            it "should allow for capturing diagonally" do 
                board = Array.new(8) { Array.new(8,nil) }
                board[5][5] = "WP"
                board[4][4] = "BP"
                chess = ChessMate.new(board)
                chess.move('f3', 'e4')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, 'WP', nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end
        end
        
        context "for rooks" do
            it "should update the board if rook moves vertically" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][0] = "WR"
                chess = ChessMate.new(board)
                chess.move('a1', 'a8')
                expect(chess.board).to eql(
                    [
                    ["WR", nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end

            it "should update the board if the rook moves horizontally" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][0] = "WR"
                chess = ChessMate.new(board)
                chess.move('a1', 'h1')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, "WR"],
                    ]
                )
            end

            it "should return false for a move that is neither horizontal or vertical" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][0] = "WR"
                chess = ChessMate.new(board)
                expect(chess.move('a1','g8')).to eql(false)
            end
        end

        context "for bishops" do
            it "should update the board if the bishop moves diagonally" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][1] = "WB"
                chess = ChessMate.new(board)
                chess.move('b1', 'h7')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, 'WB'],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end

            it "should return false for a move that is not diagonal" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][1] = "WB"
                chess = ChessMate.new(board)
                expect(chess.move('b1','b8')).to eql(false)
                
            end
        end

        context "for knights" do
            it "should update the board if the knight moves 2 horizontal, 1 vertical" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][2] = "WN"
                chess = ChessMate.new(board)
                chess.move('c1', 'e2')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, 'WN', nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end
            
            it "should update the board if the knight moves 1 horizontal, 2 vertical" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][2] = "WN"
                chess = ChessMate.new(board)
                chess.move('c1', 'd3')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, 'WN', nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end

            it "should return false if the move is invalid" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][2] = "WN"
                chess = ChessMate.new(board)
                expect(chess.move('c1','c8')).to eql(false)
            end
        end

        context "for queens" do
            it "should update the board if the queen moves vertically" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][3] = "WQ"
                chess = ChessMate.new(board)
                chess.move('d1', 'd8')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, "WQ", nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end

            it "should update the board if the queen moves horizontally" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][3] = "WQ"
                chess = ChessMate.new(board)
                chess.move('d1', 'h1')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, "WQ"],
                    ]
                )
            end

            it "should update the board if the queen moves diagonally" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][3] = "WQ"
                chess = ChessMate.new(board)
                chess.move('d1', 'h5')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, "WQ"],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end

            it "should return false if the queen makes an otherwise invalid move" do 
                board = Array.new(8) { Array.new(8,nil) }
                board[7][3] = "WQ"
                chess = ChessMate.new(board)
                expect(chess.move('d1', 'h8')).to eql(false)
            end
        end

        context "for kings" do
            it "should update the board if the king moves 1 space vertically" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][4] = "WK"
                chess = ChessMate.new(board)
                chess.move('e1', 'e2')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, "WK", nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end

            it "should update the board if the king moves 1 space horizontally" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][4] = "WK"
                chess = ChessMate.new(board)
                chess.move('e1', 'f1')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, "WK", nil, nil],
                    ]
                )
            end

            it "should update the board if the king moves 1 space diagonally" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][4] = "WK"
                chess = ChessMate.new(board)
                chess.move('e1', 'f2')
                expect(chess.board).to eql(
                    [
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    [nil, nil, nil, nil, nil, "WK", nil, nil],
                    [nil, nil, nil, nil, nil, nil, nil, nil],
                    ]
                )
            end

            it "should return false if the king makes an otherwise invalid move" do
                board = Array.new(8) { Array.new(8,nil) }
                board[7][4] = "WK"
                chess = ChessMate.new(board)
                expect(chess.move('e1', 'h8')).to eql(false)
            end
        end
    end
end