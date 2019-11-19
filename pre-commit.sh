#!/usr/bin/env ruby

require 'english'
require 'rubocop'

ADDED_OR_MODIFIED = /A|AM|^M/.freeze

changed_files = `git status --porcelain`.split(/\n/).
    select { |file_name_with_status|
      file_name_with_status =~ ADDED_OR_MODIFIED
    }.
    map { |file_name_with_status|
      file_name_with_status.split(' ')[1]
    }.
    select { |file_name|
      File.extname(file_name) == '.rb'
    }.join(' ')

success = system(%(rubocop #{changed_files}))

STDIN.reopen('/dev/tty')

if success == false
  puts "Would you like to continue press 'any key' or 'n/N' to halt?"
  exit(1) if %w(N n).include?(gets.chomp)
end