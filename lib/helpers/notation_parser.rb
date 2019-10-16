# frozen_string_literal: true

module NotationParser
  def self.parse_notation(square)
    col = square[0].downcase.ord - 97
    row = 7 - (square[1].to_i - 1)

    return nil unless col >= 0 && col < 8 && row >= 0 && row < 8

    [row, col]
  end

  def self.encode_notation(coords)
    row, col = coords

    return nil unless col >= 0 && col < 8 && row >= 0 && row < 8

    col = (col + 97).chr
    row = (8 - row).to_s
    col + row
  end
end
