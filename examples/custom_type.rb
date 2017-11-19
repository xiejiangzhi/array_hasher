f = ArrayHasher.new_formatter([
  [:a, :int], [:b, :float], [:c, :my_arr], [:d, nil, range: 3..-1]
])
f.define_type(:my_arr) {|v| v.split(',').map(&:to_i) }
# or
# f.types[:my_arr] = proc {|v| v.split(',').map(&:to_i) }
puts f.parse(['number: 123', '$ 123.1', '1,2,3', 'd1', 'd2', 'd3'])

