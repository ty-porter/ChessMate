require "spec_helper"
require_relative '../lib/helpers/notation_parser'

describe "NotationParser" do 
	
	LTRS = {
		'a' => 0,
		'b' => 1,
		'c' => 2,
		'd' => 3,
		'e' => 4,
		'f' => 5,
		'g' => 6,
		'h' => 7
	}
	
	it "should parse chess notation to an array of coords" do 
		10.times do 
			ltr = 'abcdefgh'.chars.sample
			num = rand(1..8).to_s
			notation = ltr + num
			expect(NotationParser.parse_notation(notation)).to eql(
				[
					7 - (num.to_i - 1),
					LTRS[ltr]
				]
			)
		end
	end

	context "encode_notation method" do 
		it "should encode an array of coords as chess notation" do 
			10.times do 
				y = rand(0..7)
				x = rand(0..7)
				coords = [y,x]
				ltr = LTRS.key(x)
				num = (8 - y).to_s
				notation = ltr + num
				expect(NotationParser.encode_notation(coords)).to eql(notation)
			end
		end
	end
end
