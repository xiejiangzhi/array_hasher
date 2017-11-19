require "array_hasher/version"

require "array_hasher/formatter"

require 'csv'
require 'json'

module ArrayHasher
  class << self
    def new_formatter(cols)
      Formatter.new(cols)
    end

    def parse_format(definition)
      definition.map do |val|
        name, type, opts = val.to_s.split(':', 3)

        [
          (name && name.length > 0) ? name.to_sym : nil,
          (type && type.length > 0) ? type.to_sym : nil,
          (opts && opts =~ /\A\{.*\}\z/) ? JSON.parse(opts) : {}
        ]
      end
    end

    def csv_each(path, ext_types = {}, &block)
      csv = CSV.open(path)
      formatter = new_formatter(parse_format(csv.gets))
      formatter.types.merge!(ext_types)
      csv.each { |line| block.call(formatter.parse(line)) }
    end
  end
end
