require_relative '../source'

class BufferedGroupBy < GS::ETL::Source
  attr_accessor :group_by_fields, :join_fields

  def initialize(group_by_fields, join_fields)
    self.group_by_fields = group_by_fields
    self.join_fields = join_fields
    @rows = []
    @hash = {}
  end

  def process(row)
    key = row.select { |f| group_by_fields.include?(f) }
    @hash[key] ||= {}
    join_fields.each do |field|
      @hash[key][field] ||= []
      @hash[key][field] << row[field]
    end
    nil
  end

  def output_data
    @hash.each_pair do |key, h|
      h.each_pair do |k,v|
        h[k] = v.uniq.join(',') if v.is_a?(Array)
      end
    end
    @hash.map do |k,v|
      k.merge(v)
    end
  end

  def each
    data = output_data
    data.each do |row|
      record(:'Row unbuffered')
      yield(row)
    end
  end
end
