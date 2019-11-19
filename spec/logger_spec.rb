# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/helpers/logger'

describe 'Logger' do
  before :each do
    @odd_moves_board = [
      [nil, nil, nil, 'BR', nil, nil, nil, 'BR'],
      ['BB', nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, 'BB', nil, nil, nil, nil],
      ['WR', nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, 'WQ', nil, nil, 'WQ'],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      ['WR', nil, nil, nil, nil, nil, nil, 'WQ']
    ]

    @normal_moves_board = [
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      ['WP', 'WN', 'WB', 'WQ', 'WK', nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil]
    ]

    @capture_moves_board = [
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil],
      ['BP', nil, nil, nil, nil, nil, nil, nil],
      [nil, 'BP', nil, 'BP', nil, nil, nil, nil],
      ['WP', 'WN', 'WB', 'WQ', 'WK', nil, nil, nil],
      [nil, nil, nil, nil, nil, nil, nil, nil]
    ]
  end
  context 'pawn moves' do
    it 'should log normal pawn moves' do
      logger = Logger.new([6, 0], [5, 0], @normal_moves_board)
      expect(logger.log_move).to eql('a3')
    end

    it 'should log capturing moves' do
      logger = Logger.new([6, 0], [5, 1], @capture_moves_board)
      expect(logger.log_move).to eql('axb3')
    end
  end

  context 'knight moves' do
    it 'should log normal knight moves' do
      logger = Logger.new([6, 1], [4, 0], @normal_moves_board)
      expect(logger.log_move).to eql('Na4')
    end

    it 'should log capturing moves' do
      logger = Logger.new([6, 1], [4, 0], @capture_moves_board)
      expect(logger.log_move).to eql('Nxa4')
    end
  end

  context 'bishop moves' do
    it 'should log normal bishop moves' do
      logger = Logger.new([6, 2], [5, 1], @normal_moves_board)
      expect(logger.log_move).to eql('Bb3')
    end

    it 'should log capturing moves' do
      logger = Logger.new([6, 2], [5, 1], @capture_moves_board)
      expect(logger.log_move).to eql('Bxb3')
    end
  end

  context 'queen moves' do
    it 'should log normal queen moves' do
      logger = Logger.new([6, 3], [5, 3], @normal_moves_board)
      expect(logger.log_move).to eql('Qd3')
    end

    it 'should log capturing moves' do
      logger = Logger.new([6, 3], [5, 3], @capture_moves_board)
      expect(logger.log_move).to eql('Qxd3')
    end
  end

  context 'king moves' do
    it 'should log normal king moves' do
      logger = Logger.new([6, 4], [5, 4], @normal_moves_board)
      expect(logger.log_move).to eql('Ke3')
    end

    it 'should log capturing moves' do
      logger = Logger.new([6, 4], [5, 3], @capture_moves_board)
      expect(logger.log_move).to eql('Kxd3')
    end
  end
end
