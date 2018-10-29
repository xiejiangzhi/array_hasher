require 'bundler/setup'
require 'array_hasher'

f = ArrayHasher.new_formatter([
  [:a, :int], [:b, :float], [:c, proc { |v| v.split(',') }], [:d, nil, range: 3..-1]
])
puts f.parse(['number: 123', '$ 123.1', 'a,b,c', 'd1', 'd2', 'd3'])
