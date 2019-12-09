# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'chessmate'
  s.version     = '0.8.1'
  s.date        = '2019-10-21'
  s.summary     = 'Chess for Rails'
  s.description = 'A simple chess move validator'
  s.authors     = ['Tyler Porter']
  s.email       = 'tyler.b.porter@gmail.com'
  s.files       = Dir['**/*'].keep_if { |file| !file.match('gem') && File.file?(file) }

  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rspec', '~> 0'
  s.add_development_dependency 'rubocop', '0.75.1'

  s.add_dependency 'deep_dup', '~> 0'

  s.license     = 'MIT'
  s.homepage    = 'https://rubygems.org/gems/chessmate'
  s.metadata    = { 'source_code_uri' => 'https://github.com/pawptart/chessmate' }
end
