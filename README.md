ArrayHasher

[![Gem Version](https://badge.fury.io/rb/array_hasher.svg)](https://badge.fury.io/rb/array_hasher)

[![Build Status](https://travis-ci.org/xiejiangzhi/arrah_hasher.svg?branch=master)](https://travis-ci.org/xiejiangzhi/arrah_hasher)

Format Array data to a hash with your definition. it also can parse the CSV file with definition of title.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'array_hasher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install array_hasher


## Usage

### Format array

New a formatter

```
require 'array_hasher'

f = ArrayHasher.new_formatter([
  [:a, :int], [:b, :float], [:c, proc {|v| v.split(',') }], [:d, nil, range: 3..-1]
])
```

Parse array

```
f.parse(['number: 123', '$ 123.1', 'a,b,c', 'd1', 'd2', 'd3'])
# => {a: 123, b: 123.1, c: ['a', 'b', 'c'], d: ['d1', 'd2', 'd3']}
```

Define your data type

```
f.define_type(:my_arr) {|v| v.split(',').map(&:to_i) }
f.cols[2] = [:c, :my_arr]
f.parse(['number: 123', '$ 123.1', '1,2,3', 'd1', 'd2', 'd3'])
# => {a: 123, b: 123.1, c: [1, 2, 3], d: ['d1', 'd2', 'd3']}
```

### Format CSV

CSV file

```
name:bookname,price:float,"tags::{""range"": [2, 3]}",,
Hello,$1.20,A,B,C
World,$ 3.20,B,C,What’s this?
My book,USD 4.3,C,123,
Your book,1.2,Hehe,Haha,666
```

Define our data type and parser 

```
# `bookname` type was used in that CSV file
# We can define this type, it will tell parser how to parse data of bookname
ext_types = {bookname: proc {|v| "<#{v}>" }}
ArrayHasher.csv_each('path/to/test.csv', ext_types) do |line|
  puts line
end

# {:name=>"<Hello>", :price=>1.2, :tags=>["A", "B", "C"]}
# {:name=>"<World>", :price=>3.2, :tags=>["B", "C", "What’s this?"]}
# {:name=>"<My book>", :price=>4.3, :tags=>["C", "123", nil]}
# {:name=>"<Your book>", :price=>1.2, :tags=>["Hehe", "Haha", "666"]}
```

### Put multiple columns to one key.

```
# We can append a `range` option as third arguments
# `range` also can be used in CSV title
format = ArrayHasher.parse_formatter([
  'name:string',
  'price:float',
  'attrs:arr:{range: 2..-1}'
])
# => [[:name, :string], [:price, :float], [:attrs, :arr, range: 2..-1]]

ArrayHasher.new_formatter(format)
```


### Examples
  
See [Here](./examples)

## Default Types

* `int` # convert string to int
* `float` # convert string to float
* `string`: # to_s
* `time` # Time.parse(string)
* `Proc` # format the value with your proc. we can define a Proc in our code only.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/array_hasher.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
