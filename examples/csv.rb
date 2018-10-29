require 'bundler/setup'
require 'array_hasher'

puts "Undefined data type 'bookname'"
ArrayHasher.csv_each(File.expand_path('../test.csv', __FILE__)) do |line|
  puts line
end

puts "\nDefined 'bookname' wrap with <>"
ext_types = { bookname: proc { |v| "<#{v}>" } }
ArrayHasher.csv_each(File.expand_path('../test.csv', __FILE__), ext_types) do |line|
  puts line
end
