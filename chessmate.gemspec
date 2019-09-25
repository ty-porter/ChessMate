Gem::Specification.new do |s|
  s.name        = 'chessmate'
  s.version     = '0.1.0'
  s.date        = '2018-09-23'
  s.summary     = "Chess for Rails"
  s.description = "A simple chess move validator"
  s.authors     = ["Tyler Porter"]
  s.email       = 'tyler.b.porter@gmail.com'
  s.files       = Dir['**/*'].keep_if { |file| !file.match('gem') && File.file?(file) }
  s.add_development_dependency "rspec"
  s.license     = 'MIT'
  s.homepage    = 'https://rubygems.org/gems/chessmate'
  s.metadata    = { "source_code_uri" => "https://github.com/pawptart/chessmate" }
end