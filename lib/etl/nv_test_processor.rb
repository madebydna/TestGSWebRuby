# coding: utf-8
require "set"
require_relative "test_processor"

# NOTES:
# - What to do with new schools

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
    @name_id_map_path = File.join(@input_dir, 'nv_name_id_map.txt')
    @subject_id_map = {
      'reading' => '2',
      'writing' => '3',
      'math' => '5',
      'science' => '25'
    }
    @prof_id_map = {
      'null' => 'null',
      'emergent_developing' => '58',
      'approaches_standard' => '59',
      'meets_standard' => '60',
      'exceeds_standard' => '61'
    }
    @prof_map = {
      '___proficient' => 'null',
      '__emergentdeveloping' => 'emergent_developing',
      '__approaches_standard' => 'approaches_standard',
      '__meets_standard' => 'meets_standard',
      '__exceeds_standard' => 'exceeds_standard'
    }
    @current_entity_info = nil
  end

  source(/CRT Grade [58] School.csv/, []) do |s|
    s.transform('Add entity and breakdown ids', WithBlock) do |row|
      group = row[:group]
      if @current_entity_info && (breakdown_id = @breakdowns[group])
        row.merge! breakdown: group, breakdown_id: breakdown_id
        row.merge! @current_entity_info
      elsif @current_entity_info = find_entity_info(group)
        row.merge! breakdown_id: 1, breakdown: 'all'
        row.merge! @current_entity_info
      else
        @current_entity_info = nil
        if !@breakdowns[group] then puts group end
      end
    end
      .transform('Transpose out science proficiency bands',
        Transposer, :prof_subject, :value_float, *subject_prof_bands('science'))
      .transform('Fill test_data_type',
        Fill, test_data_type: 'crt', test_data_type_id: 90)
  end

  # source('HSPE School.csv', [], max: nil) do |s|
  #   s.transform('Add entity and breakdown ids', WithBlock) do |row|
  #     group = row[:group]
  #     if @current_entity_info && (breakdown_id = @breakdowns[group])
  #       row.merge! breakdown: group, breakdown_id: breakdown_id
  #       row.merge! @current_entity_info
  #     elsif @current_entity_info = find_entity_info(group)
  #       puts group
  #       row.merge! breakdown_id: 1, breakdown: 'all'
  #       row.merge! @current_entity_info
  #     else
  #       @current_entity_info = nil
  #       if !@breakdowns[group] then end
  #     end
  #     nil
  #   end
  #     .transform('Transpose out science proficiency bands',
  #       Transposer, :prof_subject, :value_float, *subject_prof_bands('science'))
  #     .transform('Fill test_data_type',
  #       Fill, test_data_type: 'crt', test_data_type_id: 90)
  # end

  shared do |s|
    s.transform('Split subject and proficiency band', WithBlock) do |row|
        subject, prof_band_str = row.delete(:prof_subject).to_s.match(/(\A[^_]+)(.*)/)[1..2]
        row[:subject] = subject
        row[:subject_id] = @subject_id_map[subject]
        row[:proficiency_band] = @prof_map[prof_band_str]
        row[:proficiency_band_id] = @prof_id_map[prof_band_str]
        row[:number_tested] = row.delete((subject+'__number_tested').to_sym)
        row
    end
      .transform("Fill year", Fill, year: '2015')
      .transform('', WithBlock) do |row|
      row
    end

  end

  def subject_prof_bands(*subjects)
    subjects.map do |subject|
      @prof_map.keys.map { |suffix| (subject+suffix).to_sym }
    end.flatten
  end

  def find_entity_info(name)
    name = name.downcase
    result = info_from_name[name]
    until result || name.length == 0
      name.gsub!(/\s*\S+\Z/, '')
      result = info_from_name[name]
    end
    result
  end

  def info_from_name
    if @info_from_name
      @info_from_name
    else
      make_crt_name_id_map_file
      @info_from_name = CsvSource.new(@name_id_map_path, [], col_sep: "\t")
        .each_with_object({}) do |row, memo|
          row = row.to_hash
          entity_info = { entity_level: row[:entity_level] }

          if row[:entity_level] == 'school'
            entity_info.merge! school_name: row[:name], school_id: row[:id]
          elsif row[:entity_level] == 'district'
            entity_info.merge! district_name: row[:name], district_id: row[:id]
          end
          memo[row[:name]] = entity_info
        end
    end
  end

  def make_crt_name_id_map_file
    return if File.exist?(@name_id_map_path)
    source = CsvSource.new('data/nv/nv_crt_2014.txt', [], col_sep: "\t")
    agg = source.transform("Generate school name and id mapping", NameMappingAggregator)
    agg.destination('Output name / id keymap', CsvDestination, @name_id_map_path)
    source.run
    agg.run
  end

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
end

class NameMappingAggregator < GS::ETL::Source

  def initialize
    @schools_seen = {}
    @dup_names = Set.new(["Eureka", "Lincoln", "Allen"])
  end

  def process(row)
    return if (@schools_seen.include?(row[:name]) || @dup_names.include?(row[:name]))
    @schools_seen[row[:name]] = [row[:id], row[:entity]]
    nil
  end

  def each
    @schools_seen.each do |k, v|
      row = { name: k.downcase, id: v[0], entity_level: v[1]}
      yield row
    end
  end
end

NVTestProcessor.new("data/nv").run
