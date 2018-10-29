
RSpec.describe ArrayHasher::Formatter do
  let(:subject) do
    ArrayHasher::Formatter.new([
      [:name, :string],
      [:quantity, :int],
      [:price, :float],
      [:time, :time],
      [:number, proc { |v| v.to_i * 3 }],
      [:unknown, :asdf],
      [:ext_data, :json],
      [:bd, :date]
    ])
  end

  describe '#parse' do
    it 'should convert array to hash' do
      expect(subject.parse([
        "hello", "12,400", "$12.45", "2017-10-25 13:22:14", '33', 'a', '{"str": [1, 2]}', '2018-1-1', 'b'
      ])).to eql(
        name: 'hello',
        quantity: 12400,
        price: 12.45,
        time: Time.parse("2017-10-25 13:22:14"),
        number: 99,
        unknown: 'a',
        ext_data: { 'str' => [1, 2] },
        bd: Date.parse('2018-1-1')
      )

      expect(subject.parse([
        "world123", "abc13", "$ 12", "2017-10-25", '1', 123, '["str", 1, 2]', '2018-1-1 11:22'
      ])).to eql(
        name: 'world123',
        quantity: 13,
        price: 12.0,
        time: Time.parse("2017-10-25"),
        number: 3,
        unknown: 123,
        ext_data: ['str', 1, 2],
        bd: Date.parse('2018-1-1')
      )
    end

    it 'should ignore colum if its name is nil' do
      f = ArrayHasher::Formatter.new([[], [:b, :int]])
      expect(f.parse(['123', '123'])).to eql(b: 123)
    end

    it 'should use specified range as val' do
      f = ArrayHasher::Formatter.new([
        [:a, proc { |v| v[-1] }, range: 0..2],
        [:b, :string, range: [1, 2]],
        [:c, nil, range: 1..2]
      ])
      expect(f.parse(['123', '122', '133', '144'])).to eql(
        a: '133',
        b: "[\"122\", \"133\"]",
        c: ['122', '133']
      )
    end

    it 'should convert nil array' do
      expect(subject.parse([
        nil, nil, nil, nil, nil, nil, nil, nil
      ])).to eql(
        name: '', quantity: nil, price: nil, time: nil, number: 0,
        ext_data: nil, bd: nil, unknown: nil
      )
    end
  end

  describe '#define_type' do
    let(:f) { ArrayHasher::Formatter.new([[:a, :int], [:b, :time], [:c, :my_type]]) }
    let(:data) { ['a', '2017-1-1', 'c', 'd'] }

    it 'should support define a new type' do
      expect(f.parse(data)).to eql(a: 0, b: Time.parse('2017-1-1'), c: 'c')
      f.define_type(:my_type) { |v| "-#{v}-" }
      expect(f.parse(data)).to eql(a: 0, b: Time.parse('2017-1-1'), c: '-c-')
    end
  end

  describe 'r/w cols' do
    let(:f) { ArrayHasher::Formatter.new([[:a, :int], [:b, 'time'], ['c', :my_type]]) }
    let(:data) { ['a', '2017-1-1', 'c', 'd'] }

    before :each do
      f.define_type(:my_type) { |v| "-#{v}-" }
    end

    it 'can read the definition of columns' do
      expect(f.cols).to eql([[:a, :int, {}], [:b, :time, {}], [:c, :my_type, {}]])
    end

    it 'can redefine columns' do
      expect(f.parse(data)).to eql(a: 0, b: Time.parse('2017-1-1'), c: '-c-')

      f.cols[1] = [:b, :my_type]
      expect(f.parse(data)).to eql(a: 0, b: '-2017-1-1-', c: '-c-')

      f.cols[1] = [:b, nil, range: 2..-1]
      expect(f.parse(data)).to eql(a: 0, b: ['c', 'd'], c: '-c-')
    end
  end
end
