RSpec.describe ArrayHasher do
  it "has a version number" do
    expect(ArrayHasher::VERSION).not_to be nil
  end

  describe '.new_formatter' do
    it 'should call ArrayHasher::Formatter.new' do
      expect(ArrayHasher::Formatter).to receive(:new).with([[:a, :int]])
      ArrayHasher.new_formatter([[:a, :int]])
    end
  end

  describe '.parse_format' do
    it 'should parse a array of format' do
      expect(ArrayHasher.parse_format(%w{name:int price:float other:my_type})).to \
        eql([[:name, :int, {}], [:price, :float, {}], [:other, :my_type, {}]])

      expect(ArrayHasher.parse_format(['name', 'price:', nil])).to \
        eql([[:name, nil, {}], [:price, nil, {}], [nil, nil, {}]])
    end

    it 'should parse json opts' do
      expect(ArrayHasher.parse_format(['name:int', 'tags:string:{"a": [1,2]}'])).to \
        eql([[:name, :int, {}], [:tags, :string, 'a' => [1, 2]]])
    end
  end

  describe '.csv_each' do
    it 'should parse csv by its title' do
      data = []
      ext_types = {bookname: proc {|v| "<#{v}>" }}
      ArrayHasher.csv_each('spec/test_files/a.csv', ext_types) {|line| data << line }
      expect(data).to eql([
        {name: "<Hello>", price: 1.2, tags: ["A", "B", "C"]},
        {name: "<World>", price: 3.2, tags: ["B", "C", "What’s this?"]},
        {name: "<My book>", price: 4.3, tags: ["C", "123", nil]},
        {name: "<Your book>", price: 1.2, tags: ["Hehe", "Haha", "666"]}
      ])
    end
  end
end
