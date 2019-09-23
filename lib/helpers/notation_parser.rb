LETTERS = {"a" => 0, "b" => 1, "c" =>  2, "d" => 3, "e" =>  4, "f" =>  5, "g" =>  6, "h" =>  7}

module NotationParser
	def NotationParser.parse_notation(square)
		ltr = LETTERS[square[0].downcase()]
		num = square[1].to_i - 1

		[ltr, num]
	end
end