# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/chessmate'
require_relative '../lib/helpers/notation_parser'
require_relative '../lib/helpers/default'
Dir['../lib/pieces/*.rb'].each { |file| require file }

describe ChessMate do
  describe 'initialize method' do
    context 'should accept custom parameters' do
      it 'for board' do
        board = Array.new(8) { Array.new(8, nil) }
        chess = ChessMate.new(board: board)
        expect(chess.board).to eql(board)
      end

      it 'for en_passant' do
        en_passant = { white: true, black: nil }
        chess = ChessMate.new(en_passant: en_passant)
        expect(chess.en_passant).to eql(en_passant)
      end

      it 'for castling' do
        castling = {
          white: {
            kingside: false,
            queenside: true
          },
          black: {
            kingside: true,
            queenside: true
          }
        }
        chess = ChessMate.new(castling: castling)
        expect(chess.castling).to eql(castling)
      end

      it 'for turn' do
        turn = rand(10)
        chess = ChessMate.new(turn: turn)
        expect(chess.turn).to eql(turn)
      end

      it 'for in_check' do
        in_check = { "white": true, "black": false }
        chess = ChessMate.new(in_check: in_check)
        expect(chess.in_check).to eql(in_check)
      end

      it 'for allow_out_of_turn' do
        chess = ChessMate.new(allow_out_of_turn: true)
        expect(chess.allow_out_of_turn).to eql(true)
      end
    end

    context 'no custom parameters' do
      it 'should generate a default game' do
        chess = ChessMate.new
        expect(chess.board).to eql(DEFAULT[:board])
        expect(chess.turn).to eql(DEFAULT[:turn])
        expect(chess.promotable).to eql(nil)
        expect(chess.en_passant).to eql(DEFAULT[:en_passant])
        expect(chess.castling).to eql(DEFAULT[:castling])
        expect(chess.in_check).to eql(DEFAULT[:in_check])
      end
    end
  end

  describe 'board method' do
    before :each do
      @chess = ChessMate.new
    end

    it 'should return the board state' do
      expect(@chess.board).to eql(DEFAULT[:board])
    end
  end

  describe 'update method' do
    before :each do
      @chess = ChessMate.new
    end

    it 'should update the board after moving' do
      @chess.update([6, 0], [5, 0])
      expect(@chess.board).to eql(
        [
          %w[BR BN BB BQ BK BB BN BR],
          %w[BP BP BP BP BP BP BP BP],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          ['WP', nil, nil, nil, nil, nil, nil, nil],
          [nil, 'WP', 'WP', 'WP', 'WP', 'WP', 'WP', 'WP'],
          %w[WR WN WB WQ WK WB WN WR]
        ]
      )
    end

    it 'should update the turn on a successful update' do
      turn = @chess.turn
      @chess.update([6, 0], [5, 0])
      expect(@chess.turn).to eql(turn + 1)
    end
  end

  describe 'turn method' do
    it 'should show the current turn' do
      chess = ChessMate.new
      expect(chess.turn).to eql(1)
    end
  end

  describe 'in_check method' do
    it 'should return a hash of values values on game start' do
      chess = ChessMate.new
      expect(chess.in_check).to eql(
        "white": false,
        "black": false
      )
    end
  end

  describe 'in_check? method' do
    it 'should return a hash value' do
      chess = ChessMate.new
      check = chess.in_check?
      expect(check.is_a?(Hash)).to eql(true)
    end

    it 'should handle a malformed board by returning default value' do
      board = Array.new(8) { Array.new(8, nil) }
      chess = ChessMate.new(board: board)
      expect(chess.in_check?).to eql(
        "white": false,
        "black": false
      )
    end

    it 'should should return false if neither king is in check' do
      chess = ChessMate.new
      expect(chess.in_check?).to eql(
        "white": false,
        "black": false
      )
    end

    it 'should return true if the white king is in check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[0][4] = 'BQ'
      board[0][5] = 'BK'
      chess = ChessMate.new(board: board)
      expect(chess.in_check?).to eql(
        "white": true,
        "black": false
      )
    end

    it 'should return true if the black king is in check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[7][5] = 'WQ'
      board[0][5] = 'BK'
      chess = ChessMate.new(board: board)
      expect(chess.in_check?).to eql(
        "white": false,
        "black": true
      )
    end

    it 'should not update the board to test for king in check' do
      chess = ChessMate.new
      chess.in_check?
      expect(chess.board).to eql(
        [
          %w[BR BN BB BQ BK BB BN BR],
          %w[BP BP BP BP BP BP BP BP],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          %w[WP WP WP WP WP WP WP WP],
          %w[WR WN WB WQ WK WB WN WR]
        ]
      )
    end

    it 'should not update other game params' do
      chess = ChessMate.new
      chess.in_check?
      DEFAULT.keys.each do |key|
        expect(chess.send(key)).to eql(DEFAULT[key])
      end
    end

    it 'should handle new boards being passed in' do
      board = Array.new(8) { Array.new(8, nil) }
      board[0][0] = 'BQ'
      board[7][0] = 'WK'
      chess = ChessMate.new(board: board)
      expect(chess.in_check?).to eql(
        "white": true,
        "black": false
      )
    end
  end

  describe 'move method' do
    before :each do
      @chess = ChessMate.new
    end

    context 'allow out of turn' do
      it 'by default should not let players move out of turn' do
        chess = ChessMate.new(allow_out_of_turn: false)
        expect(chess.move('a7', 'a6')).to eql(false)
        expect(chess.board).to eql(DEFAULT[:board])
        expect(chess.move('a2', 'a3')).to eql(true)
        expect(chess.move('a3', 'a4')).to eql(false)
      end

      it 'option to allow players to move out of turn' do
        chess = ChessMate.new(allow_out_of_turn: true)
        expect(chess.move('a7', 'a6')).to eql(true)
      end
    end

    it 'should test that the king is not in check before moving' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[6][0] = 'WP'
      board[0][4] = 'BK'
      board[1][4] = 'BQ'
      chess = ChessMate.new(board: board)
      chess.move('a2', 'a3')
      expect(chess.in_check?).to eql(
        "white": true,
        "black": false
      )
      expect(chess.board).to eql(
        [
          [nil, nil, nil, nil, 'BK', nil, nil, nil],
          [nil, nil, nil, nil, 'BQ', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          ['WP', nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, 'WK', nil, nil, nil]
        ]
      )
    end

    it 'should not let players move into check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[0][4] = 'BK'
      board[0][3] = 'BQ'
      chess = ChessMate.new(board: board)
      chess.move('e1', 'd1')
      expect(chess.board).to eql(
        [
          [nil, nil, nil, 'BQ', 'BK', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, 'WK', nil, nil, nil]
        ]
      )
    end

    it 'should let players move out of check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][3] = 'WK'
      board[0][4] = 'BK'
      board[0][3] = 'BQ'
      chess = ChessMate.new(board: board)
      chess.move('d1', 'e1')
      expect(chess.board).to eql(
        [
          [nil, nil, nil, 'BQ', 'BK', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, 'WK', nil, nil, nil]
        ]
      )
    end

    it 'should update in_check? if opposite color is in check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[0][4] = 'BK'
      board[1][3] = 'BQ'
      chess = ChessMate.new(board: board)
      chess.move('d7', 'e7')
      expect(chess.board).to eql(
        [
          [nil, nil, nil, nil, 'BK', nil, nil, nil],
          [nil, nil, nil, nil, 'BQ', nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, 'WK', nil, nil, nil]
        ]
      )
      expect(chess.in_check?[:white]).to eql(true)
    end

    it 'should return false if the move is not within the bounds of the board' do
      expect(@chess.move('z2', 'c3')).to eql(false)
      expect(@chess.board).to eql(
        [
          %w[BR BN BB BQ BK BB BN BR],
          %w[BP BP BP BP BP BP BP BP],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          %w[WP WP WP WP WP WP WP WP],
          %w[WR WN WB WQ WK WB WN WR]
        ]
      )
    end

    it 'should return false if the origin or destination are malformed' do
      expect(@chess.move('22', 'c3')).to eql(false)
      expect(@chess.move('zz', 'c3')).to eql(false)
    end

    it 'should generally return false and not update the board if the path is blocked' do
      expect(@chess.move('d1', 'a1')).to eql(false)
      expect(@chess.move('d1', 'd8')).to eql(false)
      expect(@chess.move('d1', 'b3')).to eql(false)
      expect(@chess.board).to eql(
        [
          %w[BR BN BB BQ BK BB BN BR],
          %w[BP BP BP BP BP BP BP BP],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          %w[WP WP WP WP WP WP WP WP],
          %w[WR WN WB WQ WK WB WN WR]
        ]
      )
    end

    it 'should return false if there is a promotable pawn on the board' do
      board = [
        ['WP', nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        ['WP', nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
      chess = ChessMate.new(board: board, promotable: [0, 0])
      expect(chess.move('a2', 'a3')).to eql(false)
    end

    context 'for pawns' do
      it 'should update the board if pawn move is valid' do
        @chess.move('c2', 'c3')
        expect(@chess.board).to eql(
          [
            %w[BR BN BB BQ BK BB BN BR],
            %w[BP BP BP BP BP BP BP BP],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, 'WP', nil, nil, nil, nil, nil],
            ['WP', 'WP', nil, 'WP', 'WP', 'WP', 'WP', 'WP'],
            %w[WR WN WB WQ WK WB WN WR]
          ]
        )
      end

      it 'should return false if the pawn move is invalid' do
        expect(@chess.move('c2', 'd3')).to eql(false)
      end

      it "should update the board if pawn's first move is 2 squares" do
        chess = ChessMate.new
        chess.move('c2', 'c4')
        expect(chess.board).to eql(
          [
            %w[BR BN BB BQ BK BB BN BR],
            %w[BP BP BP BP BP BP BP BP],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, 'WP', nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            ['WP', 'WP', nil, 'WP', 'WP', 'WP', 'WP', 'WP'],
            %w[WR WN WB WQ WK WB WN WR]
          ]
        )
        chess = ChessMate.new
        chess.move('b7', 'b5')
        expect(chess.board).to eql(
          [
            %w[BR BN BB BQ BK BB BN BR],
            ['BP', nil, 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, 'BP', nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            %w[WP WP WP WP WP WP WP WP],
            %w[WR WN WB WQ WK WB WN WR]
          ]
        )
      end

      it 'should not allow a pawn to move 2 spaces if the 1st space is occupied' do
        board = Array.new(8) { Array.new(8, nil) }
        board[6][0] = 'WP'
        board[5][0] = 'BP'
        chess = ChessMate.new(board: board)
        chess.move('a2', 'a4')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            ['BP', nil, nil, nil, nil, nil, nil, nil],
            ['WP', nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should allow for capturing diagonally' do
        board = Array.new(8) { Array.new(8, nil) }
        board[5][5] = 'WP'
        board[4][4] = 'BP'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow for capturing forwards' do
        board = Array.new(8) { Array.new(8, nil) }
        board[5][4] = 'WP'
        board[4][4] = 'BP'
        chess = ChessMate.new(board: board)
        chess.move('e3', 'e4')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'BP', nil, nil, nil],
            [nil, nil, nil, nil, 'WP', nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow pawns to move backwards to capture' do
        board = Array.new(8) { Array.new(8, nil) }
        board[4][4] = 'WP'
        board[5][5] = 'BP'
        chess = ChessMate.new(board: board)
        chess.move('e4', 'f3')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WP', nil, nil, nil],
            [nil, nil, nil, nil, nil, 'BP', nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow pawns to capture pieces of same color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[4][4] = 'WP'
        board[5][5] = 'WP'
        chess = ChessMate.new(board: board)
        chess.move('f3', 'e4')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WP', nil, nil, nil],
            [nil, nil, nil, nil, nil, 'WP', nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow pawns to move backwards in general' do
        board = Array.new(8) { Array.new(8, nil) }
        board[4][4] = 'WP'
        board[5][5] = 'BP'
        chess = ChessMate.new(board: board)
        chess.move('e4', 'e3')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WP', nil, nil, nil],
            [nil, nil, nil, nil, nil, 'BP', nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should flag a pawn as promotable if moving to the last rank' do
        board = Array.new(8) { Array.new(8, nil) }
        board[1][0] = 'WP'
        chess = ChessMate.new(board: board)
        chess.move('a7', 'a8')
        expect(chess.board).to eql(
          [
            ['WP', nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
        expect(chess.promotable).to eql([0, 0])
      end

      it 'should allow en passant under correct circumstances for white' do
        board = Array.new(8) { Array.new(8, nil) }
        board[1][0] = 'BP'
        board[3][1] = 'WP'
        chess = ChessMate.new(board: board)
        chess.move('a7', 'a5')
        chess.move('b5', 'a6')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            ['WP', nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should allow en passant under correct circumstances for black' do
        board = Array.new(8) { Array.new(8, nil) }
        board[4][0] = 'BP'
        board[6][1] = 'WP'
        chess = ChessMate.new(board: board)
        chess.move('b2', 'b4')
        chess.move('a4', 'b3')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, 'BP', nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow en passant after first move' do
        board = Array.new(8) { Array.new(8, nil) }
        board[1][0] = 'BP'
        board[3][1] = 'WP'
        board[6][7] = 'WP'
        board[1][7] = 'BP'
        chess = ChessMate.new(board: board)
        chess.move('a7', 'a5')
        chess.move('h2', 'h3')
        chess.move('h7', 'h6')
        chess.move('b5', 'a6')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, 'BP'],
            ['BP', 'WP', nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, 'WP'],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should work if custom en_passant is passed in' do
        board = Array.new(8) { Array.new(8, nil) }
        board[3][0] = 'BP'
        board[3][1] = 'WP'
        en_passant =  { white: nil, black: [3, 0] }
        chess = ChessMate.new(board: board, en_passant: en_passant)
        chess.move('b5', 'a6')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            ['WP', nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end
    end

    context 'for rooks' do
      it 'should update the board if rook moves vertically' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][0] = 'WR'
        chess = ChessMate.new(board: board)
        chess.move('a1', 'a8')
        expect(chess.board).to eql(
          [
            ['WR', nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should update the board if the rook moves horizontally' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][0] = 'WR'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, 'WR']
          ]
        )
      end

      it 'should return false for a move that is neither horizontal or vertical' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][0] = 'WR'
        chess = ChessMate.new(board: board)
        expect(chess.move('a1', 'g8')).to eql(false)
      end

      it 'should allow capturing pieces of opposite color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][0] = 'WR'
        board[7][7] = 'BR'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, 'WR']
          ]
        )
      end

      it 'should not allow capturing pieces of same color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][0] = 'WR'
        board[7][7] = 'WR'
        chess = ChessMate.new(board: board)
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
            ['WR', nil, nil, nil, nil, nil, nil, 'WR']
          ]
        )
      end
    end

    context 'for bishops' do
      it 'should update the board if the bishop moves diagonally' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WB'
        chess = ChessMate.new(board: board)
        chess.move('c1', 'h6')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, 'WB'],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should return false for a move that is not diagonal' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WB'
        chess = ChessMate.new(board: board)
        expect(chess.move('c1', 'c8')).to eql(false)
        expect(chess.move('c1', 'h7')).to eql(false)
        expect(chess.move('c1', 'h8')).to eql(false)
      end

      it 'should allow capturing pieces of opposite color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WB'
        board[2][7] = 'BB'
        chess = ChessMate.new(board: board)
        chess.move('c1', 'h6')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, 'WB'],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow capturing pieces of same color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WB'
        board[2][7] = 'WB'
        chess = ChessMate.new(board: board)
        chess.move('c1', 'h6')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, 'WB'],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, 'WB', nil, nil, nil, nil, nil]
          ]
        )
      end
    end

    context 'for knights' do
      it 'should update the board if the knight moves 2 horizontal, 1 vertical' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WN'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should update the board if the knight moves 1 horizontal, 2 vertical' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WN'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should return false if the move is invalid' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WN'
        chess = ChessMate.new(board: board)
        expect(chess.move('c1', 'c8')).to eql(false)
      end

      it 'should allow capturing pieces of opposite color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WN'
        board[5][3] = 'BN'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow capturing pieces of same color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][2] = 'WN'
        board[5][3] = 'WN'
        chess = ChessMate.new(board: board)
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
            [nil, nil, 'WN', nil, nil, nil, nil, nil]
          ]
        )
      end
    end

    context 'for queens' do
      it 'should update the board if the queen moves vertically' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][3] = 'WQ'
        chess = ChessMate.new(board: board)
        chess.move('d1', 'd8')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, 'WQ', nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should update the board if the queen moves horizontally' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][3] = 'WQ'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, 'WQ']
          ]
        )
      end

      it 'should update the board if the queen moves diagonally' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][3] = 'WQ'
        chess = ChessMate.new(board: board)
        chess.move('d1', 'h5')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, 'WQ'],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should return false if the queen makes an otherwise invalid move' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][3] = 'WQ'
        chess = ChessMate.new(board: board)
        expect(chess.move('d1', 'h8')).to eql(false)
      end

      it 'should allow capturing pieces of opposite color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][3] = 'WQ'
        board[7][7] = 'BQ'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, nil, nil, 'WQ']
          ]
        )
      end

      it 'should not allow capturing pieces of same color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][3] = 'WQ'
        board[7][7] = 'WQ'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, 'WQ', nil, nil, nil, 'WQ']
          ]
        )
      end
    end

    context 'for kings' do
      it 'should update the board if the king moves 1 space vertically' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'e2')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should update the board if the king moves 1 space horizontally' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        chess = ChessMate.new(board: board)
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
            [nil, nil, nil, nil, nil, 'WK', nil, nil]
          ]
        )
      end

      it 'should update the board if the king moves 1 space diagonally' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'f2')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, 'WK', nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should return false if the king makes an otherwise invalid move' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        chess = ChessMate.new(board: board)
        expect(chess.move('e1', 'h8')).to eql(false)
      end

      it 'should allow capturing pieces of opposite color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[6][4] = 'BP'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'e2')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow capturing pieces of same color' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[6][4] = 'WP'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'e2')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WP', nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, nil]
          ]
        )
      end

      it 'should allow castling kingside under correct circumstances' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[7][7] = 'WR'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'g1')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, 'WR', 'WK', nil]
          ]
        )
      end

      it 'should allow castling queenside under correct circumstances' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[7][0] = 'WR'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'c1')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, 'WK', 'WR', nil, nil, nil, nil]
          ]
        )
      end

      it 'should not allow castling if path is blocked' do
        chess = ChessMate.new
        board = chess.board.map(&:dup)
        chess.move('e1', 'g1')
        expect(chess.board).to eql(board)
      end

      it 'should not allow castling if move results in check' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[7][7] = 'WR'
        board[0][6] = 'BQ'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'g1')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, 'BQ', nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, 'WR']
          ]
        )
      end

      it 'should not allow castling if king passes through check' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[7][7] = 'WR'
        board[0][5] = 'BQ'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'g1')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, 'BQ', nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, 'WR']
          ]
        )
      end

      it 'should not allow castling if king is in check' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[7][7] = 'WR'
        board[0][4] = 'BQ'
        chess = ChessMate.new(board: board)
        chess.move('e1', 'g1')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, 'BQ', nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, 'WR']
          ]
        )
      end

      it 'should not allow castling if king has previously moved' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][3] = 'WK'
        board[7][7] = 'WR'
        chess = ChessMate.new(board: board)
        chess.move('d1', 'e1')
        chess.move('e1', 'g1')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, 'WR']
          ]
        )
      end

      it 'should not allow castling if rook has previously moved' do
        board = Array.new(8) { Array.new(8, nil) }
        board[7][4] = 'WK'
        board[7][7] = 'WR'
        chess = ChessMate.new(board: board)
        chess.move('h1', 'g1')
        chess.move('g1', 'h1')
        chess.move('e1', 'g1')
        expect(chess.board).to eql(
          [
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, 'WK', nil, nil, 'WR']
          ]
        )
      end
    end
  end

  describe 'in_check_after_move? method' do
    before :each do
      @board = Array.new(8) { Array.new(8, nil) }
      @board[7][4] = 'WK'
      @board[0][4] = 'BK'
      @board[0][3] = 'BQ'
      @chess = ChessMate.new(board: @board)
    end
    it 'should return true if the moving color is in check after the move' do
      expect(@chess.in_check_after_move?([7, 4], [7, 3])).to eql(true)
    end

    it 'should return false if the moving color is not in check after the move' do
      expect(@chess.in_check_after_move?([7, 4], [7, 5])).to eql(false)
    end

    it 'should not update the actual game board to test' do
      test_board = Array.new(8) { Array.new(8, nil) }
      test_board[7][4] = 'WK'
      test_board[0][4] = 'BK'
      test_board[0][3] = 'BQ'
      @chess.in_check_after_move?([7, 4], [7, 3])
      expect(test_board.object_id).to_not eql(@board.object_id)
      expect(test_board).to eql(@chess.board)
    end

    it 'should not mutate other game parameters' do
      chess = ChessMate.new
      chess.in_check_after_move?([6, 4], [5, 4])
      DEFAULT.keys.each do |key|
        expect(chess.send(key)).to eql(DEFAULT[key])
      end
    end

    it 'should return true if the checking piece is captured, but still results in check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[6][4] = 'BQ'
      board[3][4] = 'BK'
      board[4][4] = 'BR'
      chess = ChessMate.new(board: board)
      expect(chess.in_check_after_move?([7, 4], [6, 4])).to eql(true)
    end
  end

  describe 'valid_moves? method' do
    it 'should return true if there are valid moves' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[0][4] = 'BK'
      chess = ChessMate.new(board: board)
      expect(chess.any_valid_moves?('W')).to eql(true)
    end

    it 'should return false if there are no valid moves' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[6][4] = 'BQ'
      board[3][4] = 'BK'
      board[4][4] = 'BR'
      chess = ChessMate.new(board: board)
      expect(chess.any_valid_moves?('W')).to eql(false)
    end
  end

  describe 'checkmate? method' do
    it 'should return true if no valid moves remain and currently in check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[6][4] = 'BQ'
      board[3][4] = 'BK'
      board[4][4] = 'BR'
      chess = ChessMate.new(board: board)
      expect(chess.checkmate?('W')).to eql(true)
    end

    it 'should return false if there are valid moves' do
      chess = ChessMate.new
      expect(chess.checkmate?('W')).to eql(false)
    end
  end

  describe 'draw? method' do
    it 'should return true if no valid moves remain and currently not in check' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[5][3] = 'BQ'
      board[5][4] = 'BK'
      board[4][5] = 'BR'
      chess = ChessMate.new(board: board)
      expect(chess.draw?('W')).to eql(true)
    end

    it 'should return false if there are valid moves' do
      chess = ChessMate.new
      expect(chess.checkmate?('W')).to eql(false)
    end

    it 'should return false if checkmated' do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[6][3] = 'BQ'
      board[5][4] = 'BK'
      board[4][5] = 'BR'
      chess = ChessMate.new(board: board)
      expect(chess.draw?('W')).to eql(false)
    end
  end

  describe 'promote? method' do
    it 'should return true if white piece is moving to last rank' do
      board = Array.new(8) { Array.new(8, nil) }
      board[1][0] = 'WP'
      chess = ChessMate.new(board: board)
      expect(chess.promote?([1, 0])).to eql(true)
    end

    it 'should return true if black piece is moving to last rank' do
      board = Array.new(8) { Array.new(8, nil) }
      board[6][0] = 'BP'
      chess = ChessMate.new(board: board)
      expect(chess.promote?([6, 0])).to eql(true)
    end

    it 'should return false otherwise' do
      board = Array.new(8) { Array.new(8, nil) }
      board[2][0] = 'WP'
      board[5][0] = 'BP'
      chess = ChessMate.new(board: board)
      expect(chess.promote?([2, 0])).to eql(false)
      expect(chess.promote?([5, 0])).to eql(false)
    end
  end

  describe 'promote! method' do
    it 'should return nil if piece cannot promote' do
      board = Array.new(8) { Array.new(8, nil) }
      board[1][0] = 'WP'
      chess = ChessMate.new(board: board)
      expect(chess.promote!([1, 0], 'queen')).to eql(nil)
    end

    it 'should return nil for invalid/junk promotion data' do
      board = Array.new(8) { Array.new(8, nil) }
      board[0][0] = 'WP'
      chess = ChessMate.new(board: board)
      expect(chess.promote!([0, 0], 'king')).to eql(nil)
    end

    context 'should promote to' do
      before :each do
        board = Array.new(8) { Array.new(8, nil) }
        board[1][0] = 'WP'
        @chess = ChessMate.new(board: board)
        @chess.move('a7', 'a8')
      end

      it 'queen' do
        @chess.promote!([0, 0], 'queen')
        expect(@chess.board[0][0]).to eql('WQ')
      end

      it 'bishop' do
        @chess.promote!([0, 0], 'bishop')
        expect(@chess.board[0][0]).to eql('WB')
      end

      it 'knight' do
        @chess.promote!([0, 0], 'knight')
        expect(@chess.board[0][0]).to eql('WN')
      end

      it 'rook' do
        @chess.promote!([0, 0], 'rook')
        expect(@chess.board[0][0]).to eql('WR')
      end
    end

    context 'logging' do
      it 'should correctly handle logging promotion' do
        board = [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          ['WP', nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        chess = ChessMate.new(board: board)
        chess.move('a7', 'a8')
        chess.promote!([0, 0], 'queen')
        expect(chess.move_history[-1]).to eql('a8=(Q)')
      end
    end
  end

  describe 'en_passant method' do
    context 'en passant not possible' do
      before :each do
        @chess = ChessMate.new
      end

      it 'should return nil for white' do
        @chess.move('a2', 'a3')
        expect(@chess.en_passant[:white]).to be_nil
      end

      it 'should return nil for black' do
        @chess.move('a7', 'a6')
        expect(@chess.en_passant[:white]).to be_nil
      end
    end

    context 'en passant possible' do
      before :each do
        @chess = ChessMate.new
      end

      it 'should return coords for white' do
        @chess.move('a2', 'a4')
        expect(@chess.en_passant[:white]).to eql([4, 0])
      end

      it 'should return coords for black' do
        @chess.move('a7', 'a5')
        expect(@chess.en_passant[:black]).to eql([3, 0])
      end
    end
  end

  describe 'castling method' do
    before :each do
      board = Array.new(8) { Array.new(8, nil) }
      board[7][4] = 'WK'
      board[7][0] = 'WR'
      board[7][7] = 'WR'
      board[0][4] = 'BK'
      board[0][0] = 'BR'
      board[0][7] = 'BR'
      @chess = ChessMate.new(board: board)
    end
    context 'new game' do
      it 'should return true for both king/queenside for both colors' do
        castling = @chess.castling
        castling.keys.each do |color|
          castling[color].keys.each do |direction|
            expect(castling[color][direction]).to eql(true)
          end
        end
      end
    end

    context 'pieces moved' do
      it 'should return false for both king/queenside if king moved' do
        @chess.move('e1', 'd1')
        @chess.move('e8', 'd8')
        castling = @chess.castling
        castling.keys.each do |color|
          castling[color].keys.each do |direction|
            expect(castling[color][direction]).to eql(false)
          end
        end
      end

      it 'should return false for either side if rook moved' do
        @chess.move('a8', 'b8')
        expect(@chess.castling[:black][:queenside]).to eql(false)
        expect(@chess.castling[:black][:kingside]).to eql(true)
        @chess.move('h1', 'g1')
        expect(@chess.castling[:white][:queenside]).to eql(true)
        expect(@chess.castling[:white][:kingside]).to eql(false)
      end
    end
  end
end
