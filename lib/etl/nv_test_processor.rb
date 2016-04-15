require_relative "test_processor"

class NameMappingAggregator < GS::ETL::Source
  attr_accessor :schools_seen

  def initialize
    @schools_seen = {}
  end

  def process(row)
    if @schools_seen.key? row[:name]
      unless @schools_seen[row[:name]].include? row[:id]
        @schools_seen[row[:name]] << row[:id]
      end
    else
      @schools_seen[row[:name]] = [row[:id]]
    end
    nil
  end

  def each
    @schools_seen.first(5).each do |k, v|
      p k, v
      row = { name: k, ids: v.inspect }
      yield row
    end
  end
end

class NVTestProcessor < GS::ETL::TestProcessor
  def run
    source = CsvSource.new('data/nv/nv_crt_2014.txt', [], col_sep: "\t")
    agg = source.transform("Generate school name and id mapping", NameMappingAggregator)
    agg.transform('', WithBlock) { |row| p row }
        .destination('Output name / id keymap', CsvDestination, 'nv_keymap.txt')

    source.run
    # agg.run
    agg.each { |row| p row }
  end

  source("CRT Grade 5 District.csv", [], col_sep: ",") do |s|
    s.transform("Load CRT Grade 5 District", Fill, { entity_level: 'district' })
  end

  source("CRT Grade 5 School.csv", [], col_sep: ",") do |s|
    s.transform("Load CRT Grade 5 School", Fill, { entity_level: 'school' })
  end

  source("CRT Grade 8 District.csv", [], col_sep: ",") do |s|
    s.transform("Load CRT Grade 8 District", Fill, { entity_level: 'district'})
  end

  source("CRT Grade 8 School.csv", [], col_sep: ",") do |s|
    s.transform("Load CRT Grade 8 School", Fill, { entity_level: 'school'})
  end

  source("HSPE District.csv", [], col_sep: ",") do |s|
    s.transform("Load HSPE District", Fill, { entity_level: 'district' })
  end

  source("HSPE School.csv", [], col_sep: ",") do |s|
    s.transform("Load HSPE School.csv", Fill, { entity_level: 'school' })
  end

  shared do |s|
    s.transform("Change year range to single year",
                HashLookup, :Year, {
                    "2014-2015" => "2015"
                })
  end

  # we need to create a hash like the below dynamically
  # key_map_state_id = {
  #   "State" => :state,
  #   "Carson City" => 13,
  #   "Churchill" => 01,
  #   "Clark" => 02,
  # }
end

NVTestProcessor.new("").run