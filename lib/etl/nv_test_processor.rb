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
    @schools_seen.each do |k, v|
      row = { name: k, ids: v.join(",")}
      yield row
    end
  end
end

class NVTestProcessor < GS::ETL::TestProcessor
  # def run
  #   source = CsvSource.new('data/nv/nv_crt_2014.txt', [], col_sep: "\t")
  #   agg = source.transform("Generate school name and id mapping", NameMappingAggregator)
  #   agg.destination('Output name / id keymap', CsvDestination, 'nv_keymap.txt')
  #
  #   source.run
  #   # p agg.schools_seen.select { |k, v| v.length > 1 }
  #   agg.run
  #   # agg.each { |row| p row }
  # end

  # source("CRT Grade 5 School.csv", [], col_sep: ",") do |s|
  #   s.transform("Load CRT Grade 5 School", Fill, { entity_level: 'school' })
  # end
  #
  # source("CRT Grade 8 School.csv", [], col_sep: ",") do |s|
  #   s.transform("Load CRT Grade 8 School", Fill, { entity_level: 'school'})
  # end

  source("HSPE School.csv", [], col_sep: ",", max: 4) do |s|
    s.transform("", WithBlock) { |row| p row }
        .transform("Load HSPE School.csv", Fill, { entity_level: 'school' })
  end

  # shared do |s|
  #   s.transform("Change year range to single year",
  #               HashLookup, :Year, {
  #                   "2014-2015" => "2015"
  #               })
  # end

  def config_hash
    {
        source_id: 8,
        state: 'wa',
        notes: 'DXT-1558: WA 2015 SBAC',
        url: 'http://reportcard.ospi.k12.wa.us/DataDownload.aspx',
        file: 'wa/2015/output/wa.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end

  # Notes about duplicate schools
  # 02151 Allen ES - one has an entry for Pacific Islander
  # 16266 Allen ES - has no entry for Pacific Islander

  # we need to create a hash like the below dynamically
  # key_map_state_id = {
  #   "State" => :state,
  #   "Carson City" => 13,
  #   "Churchill" => 01,
  #   "Clark" => 02,
  # }
end

NVTestProcessor.new("data/nv").run