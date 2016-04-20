require "set"
require_relative "test_processor"

# Schools / Districts not included in 2014 nv_keymap.txt
# "Eureka"
# "Lincoln"
# "University Schools" - NEW
# "WCSD" - Washoe County School District…?
# "Allen ES"
# "Allen ES"
# "American Prep Academy" - NEW, not in 2014 file
# "Beatty ES" - we think this is the same school (K-8), but there is a “Beatty Middle” in the 2014 file
# "Beatty ES"
# "Cold Springs MS" - “Cold Springs Middle” is a duplicate in the 2014 file
# "Doral Academy" - NEW, not in 2014 file
# "Eureka Elementary School"
# "Founders Academy of Las Vegas" - NEW, not in 2014 file
# "Imagine Schools at Mountain Vi" - Imagine s at Mountain Vi
# "Learning Bridge" - NEW, not in 2014 file
# "Lemelson STEM Academy ES" - NEW, not in 2014 file
# "Lincoln ES"
# "Mater Academy of Nevada" - NEW, not in 2014 file
# "O'Roarke ES" - O%Roarke
# "Smith Valley Schools" - Smith Valley s
# "SNACS" - NEW, not in 2014 file

class NameMappingAggregator < GS::ETL::Source
  attr_accessor :schools_seen

  def initialize
    @schools_seen = {}
    @dup_names = Set.new(["Eureka", "Lincoln", "Allen"])
  end

  def process(row)
    return if @dup_names.include? row[:name] # checks that row is not a duplicate
    return if @schools_seen.include? row[:name] # checks that row has not already been
    @schools_seen[row[:name]] = [row[:id], row[:entity]]
    nil
  end

  def each
    @schools_seen.each do |k, v|
      row = { name: k.downcase, id: v[0], entity: v[1]}
      yield row
    end
  end
end

class NVTestProcessor < GS::ETL::TestProcessor
  # Notes about duplicate schools
  # 02151 Allen ES - one has an entry for Pacific Islander
  # 16266 Allen ES - has no entry for Pacific Islander

  def initialize(*args)
    super
    @breakdowns = {
        'Female' => 11,
        'Male' => 12,
        'Am In/AK Native' => 4,
        'Black' => 3,
        'Hispanic' => 6,
        'White' => 8,
        'Two or More Races' => 21,
        'Asian' => 2,
        'Pacific Islander' => 7,
        'ELL' => 15,
        'Not ELL' => 16,
        'FRL' => 9,
        'Not FRL' => 10
    }
    @current_entity_info = nil
  end

  def make_id_reference_file
    source = CsvSource.new('data/nv/nv_crt_2014.txt', [], col_sep: "\t")
    agg = source.transform("Generate school name and id mapping", NameMappingAggregator)
    agg.destination('Output name / id keymap', CsvDestination, input_filename('nv_keymap.txt'))

    source.run
    agg.run
  end

  def info_from_name
    @info_from_name ||= CsvSource.new(File.join(@input_dir, "nv_keymap.txt"), [], col_sep: "\t")
                            .each_with_object({}) do |row, memo|
                              row = row.to_hash
                              entity_info = { entity_level: row[:entity] }
                              if row[:entity] == 'school'
                                entity_info.merge! school_name: row[:name], school_id: row[:id]
                              elsif row[:entity] == 'district'
                                entity_info.merge! district_name: row[:name], district_id: row[:id]
                              end
                              memo[row[:name]] = entity_info
    end
  end

  def entity_info(name)
    name = name.downcase
    result = info_from_name[name]
    # old_name = name.clone
    until result || name.length == 0
      name.gsub!(/\s*\S+\Z/, '')
      # p name, old_name
      # if name == old_name then raise(name) end
      result = info_from_name[name]
      # old_name = name.clone
    end
    result
  end
  # source("CRT Grade 5 School.csv", [], col_sep: ",") do |s|
  #   s.transform("Load CRT Grade 5 School", Fill, { entity_level: 'school' })
  # end
  #
  # source("CRT Grade 8 School.csv", [], col_sep: ",") do |s|
  #   s.transform("Load CRT Grade 8 School", Fill, { entity_level: 'school'})
  # end

  source("CRT Grade 5 School.csv", [], col_sep: ",") do |s|
    s.transform("", WithBlock) do |row|
      group = row[:group]
      # require 'pry'; binding.pry
      if (breakdown_id = @breakdowns[group]) && @current_entity_info
        row.merge! breakdown: group, breakdown_id: breakdown_id
        row.merge! @current_entity_info
      elsif @current_entity_info = entity_info(group)
        row.merge! breakdown_id: 1, breakdown: 'all'
        row.merge! @current_entity_info
      else
        @current_entity_info = nil
        if !@breakdowns[group] then p group end
      end
      row
    end
  end

  def output_files_step_tree
    GS::ETL::Step.new
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

  # we need to create a hash like the below dynamically
  # key_map_state_id = {
  #   "State" => :state,
  #   "Carson City" => 13,
  #   "Churchill" => 01,
  #   "Clark" => 02,
  # }
end

nv = NVTestProcessor.new("data/nv").run