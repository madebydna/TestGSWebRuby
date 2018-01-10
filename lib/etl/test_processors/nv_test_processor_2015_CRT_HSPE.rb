# coding: utf-8
require_relative "../test_processor.rb"

# TODO
# - Config file

# Schools / Districts not included in
# "Eureka" - Duplicate names exist in nv_crt_2014.txt
# "Lincoln" - Duplicate names exist in nv_crt_2014.txt
# "University Schools" - NEW
# "WCSD" - Rename Washoe County School District…?
# "Allen ES" - Duplicate names exist in nv_crt_2014.txt
# "American Prep Academy" - NEW, not in 2014 file
# "Beatty ES" - we think this is the same school (K-8), but there is a “Beatty Middle” in the 2014 file
# "Cold Springs MS" - “Cold Springs Middle” is a duplicate in the 2014 file
# "Doral Academy" - NEW, not in 2014 file
# "Eureka Elementary School" - Two Elementary schools exist in nv_crt_2014.txt
# "Founders Academy of Las Vegas" - NEW, not in 2014 file
# "Imagine Schools at Mountain Vi" - Imagine s at Mountain Vi
# "Learning Bridge" - NEW, not in 2014 file
# "Lemelson STEM Academy ES" - NEW, not in 2014 file
# "Mater Academy of Nevada" - NEW, not in 2014 file
# "O'Roarke ES" - O%Roarke
# "Smith Valley Schools" - Smith Valley s
# "SNACS" - NEW, not in 2014 file

# Entities not included in 2014 HSPE
# Clark - This seems to be a district...
# Pershing - district?
# University Schools - New
# WCSD - Rename
# ASPIRE Academy High School - New
# CSNHS East - Rename
# CSNHS South - Rename
# CSNHS West - Rename
# Eagle Ridge High School - New
# Innovations Charter SEC - New
# Innovations HS - New
# Juvenile Detention 3-12 - New
# Leadership Academy of Nevada - New
# Lincoln Co Alternative - New
# Nevada Learning Academy at CCS - New
# NNVA - New
# Pathways HS (Alt) - Rename
# Pioneer HS Alt - Rename
# Rainshadow CCHS - Rename
# Red Rock Academy - New
# SSCS - New (spanish springs already exists)
# SVHS - New (spring valley already exists)
# Turning Point - New
# WPHS - New (west prep already exists)

class NVTestProcessor2015CRTHSPE < GS::ETL::TestProcessor
  # Notes about duplicate schools
  # 02151 Allen ES - one has an entry for Pacific Islander
  # 16266 Allen ES - has no entry for Pacific Islander

  attr_accessor :entity_hash

  before do
    GS::ETL::Logging.disable

    @current_entity_info = nil

    @year = 2015

    @breakdowns = {
      'Female' => 11,
      'Male' => 12,
      'Am In/AK Native' => 4,
      'Black' => 3,
      'Hispanic' => 6,
      'White' => 8,
      'Two or More Races' => 21,
      'Asian' => 2,
      'Unknown Ethnicity' => 38,
      'Pacific Islander' => 7,
      'ELL' => 15,
      'Not ELL' => 16,
      'FRL' => 9,
      'Not FRL' => 10
    }

    @subject_id_map = {
      'reading' => '2',
      'writing' => '3',
      'math' => '5',
      'science' => '25'
    }

    @proficiency_id_map = {
      'null' => 'null',
      'emergent_developing' => '58',
      'approaches_standard' => '59',
      'meets_standard' => '60',
      'exceeds_standard' => '61'
    }

    @proficiency_map = {
      '___proficient' => 'null',
      '__emergentdeveloping' => 'emergent_developing',
      '__approaches_standard' => 'approaches_standard',
      '__meets_standard' => 'meets_standard',
      '__exceeds_standard' => 'exceeds_standard'
    }

    @renames = {
      crt: {
        'beatty middle' => 'beatty es',
        'cold springs middle' => 'cold springs ms',
        'o%roarke' => 'o\'roarke es',
        'imagine s at mountain vi' => 'imagine schools at mountain vi',
        'washoe' => 'wcsd'
      },
      hspe: {
        'washoe' => 'wcsd',
        'csn east' => 'csnhs east',
        'csn south' => 'csnhs south',
        'csn west' => 'csnhs west',
        'pathways  (alt)' => 'pathways hs (alt)',
        'pioneer  alt' => 'pioneer hs alt',
        'rainshadow cc' => 'rainshadow cchs'
      }
    }

    @special_case_entities = {
      crt: {
        'eureka' => {id: '06', entity_level: 'district'},
        'eureka elementary school' => {id: '06103', entity_level: 'school'},
        'lincoln' => {id: '09', entity_level: 'district'},
        'lincoln es' => {id: '02222', entity_level: 'school'}
      },
      hspe: {
        'clark' => {id: '02', entity_level: 'district'},
        'clark hs' => {id: '02401', entity_level: 'school'},
        'pershing' => {id: '14', entity_level: 'district'},
        'pershing hs' => {id: '14601', entity_level: 'school'}
      }
    }
  end

  source(/CRT Grade [5] School.csv/, [], quote_char: '"', max: nil) do |s|
    s.add(entity_mapping_step(:crt))
      .add(replace_dashes_step)
      .add(convert_grade_to_int_step)
      .transform('Transpose out science proficiency bands',
        Transposer, :prof_subject, :value_float, *subject_prof_bands('science'))
      .transform('Fill test_data_type',
        Fill, test_data_type: 'crt', test_data_type_id: 90)
  end

  xsource('HSPE School.csv', [], quote_char: '"') do |s|
    s.add(entity_mapping_step(:hspe))
      .add(replace_dashes_step)
      .add(convert_grade_to_int_step)
      .transform('Transpose out science proficiency bands',
        Transposer, :prof_subject, :value_float, *subject_prof_bands('science'))
      .transform('Fill test_data_type',
        Fill, test_data_type: 'hspe', test_data_type_id: 91)
  end

  shared do |s|
    s.transform('Split subject and proficiency band', WithBlock) do |row|
      subject, prof_band_str = row.delete(:prof_subject).to_s.match(/(\A[^_]+)(.*)/)[1..2]
      row[:subject] = subject
      row[:subject_id] = @subject_id_map[subject]
      proficiency_band = row[:proficiency_band] = @proficiency_map[prof_band_str]
      row[:proficiency_band_id] = @proficiency_id_map[proficiency_band]
      row[:number_tested] = row.delete((subject+'__number_tested').to_sym)
      row
    end
      .transform('Fill year, level_code, and entity_type', Fill,
                 year: @year,
                 level_code: 'e,m,h',
                 entity_type: 'public_charter')
      .transform('', CatchDuplicates, true, :state_id, :breakdown_id, :proficiency_band_id, :entity_level)
  end

  def replace_dashes_step
    WithBlock.new do |row|
      row.to_a.each do |field, value|
        row[field] = nil if value == '-'
      end
      row
    end.tap { |s| s.description = 'Replace dashes with nil' }
  end

  def convert_grade_to_int_step
    WithBlock.new do |row|
      row[:grade] = row[:grade].to_i
      row
    end.tap { |s| s.description = 'Convert grade to integers' }
  end

  def entity_mapping_step(type)
    skipped_path = "#{type}_skipped.txt"
    skipped_entities_dest = CsvDestination.new(input_filename(skipped_path))

    WithBlock.new do |row|
      group = row[:group]
      if @current_entity_info && (breakdown_id = @breakdowns[group])
        row.merge!(breakdown: group, breakdown_id: breakdown_id)
        row.merge!(@current_entity_info)
        row
      elsif group == 'State Public Schools'
        nil
      elsif @current_entity_info = find_entity_info(group, type)
        row.merge!(breakdown_id: 1, breakdown: 'all')
        row.merge!(@current_entity_info)
        row
      else
        unless @breakdowns[group]
          puts "Entity not processed: #{group}"
          skipped_entities_dest.write({name: group})
        end
        nil
      end
    end.tap { |s| s.description = 'Add entity and breakdown ids' }
  end

  def subject_prof_bands(*subjects)
    subjects.map do |subject|
      @proficiency_map.keys.map { |suffix| (subject+suffix).to_sym }
    end.flatten
  end

  def find_entity_info(name, type)
    name = name.downcase
    reference_hash = entity_hash(type)
    loop do
      result = reference_hash[name]
      name.gsub!(/\s*\S+\Z/, '')
      if (result || name.length == 0)
        break result
      end
    end
  end

  def entity_hash(type)
    @entity_hashes ||= {}

    if @entity_hashes[type]
      @entity_hashes[type]
    else
      make_name_id_map_file(type)
      @entity_hashes[type] = entity_hash_from_file(type)
    end
  end

  def entity_hash_from_file(type)
    CsvSource.new(name_id_map_path(type), [], col_sep: "\t")
      .each_with_object({}) do |row, memo|
        entity_info = { entity_level: row[:entity_level] }

        if row[:entity_level] == 'school'
          entity_info.merge! school_name: row[:name], state_id: row[:id]
        elsif row[:entity_level] == 'district'
          entity_info.merge! district_name: row[:name], state_id: row[:id]
        end
        memo[row[:name]] = entity_info
    end.tap do |entity_hash|
      @renames[type].each { |from, to| entity_hash[to] = entity_hash.delete(from) }
      entity_hash.merge! @special_case_entities[type]
    end
  end

  def make_name_id_map_file(type)
    map_path = name_id_map_path(type)
    return if File.exist? map_path

    duplicates_path = input_filename "#{type}_duplicates.txt"

    source = CsvSource.new(map_source_path(type), [], col_sep: "\t")
    agg = source.transform("Generate school name and id mapping", NameMappingAggregator)

    source.run

    begin
      map_dest = agg.transform('Select normal records', WithBlock) do |row|
        row[:name] && row
      end
        .destination('Output name to id map', CsvDestination, map_path)

      dup_dest = agg.transform('Select duplicate names', WithBlock) do |row|
        row[:duplicate] && row
      end
        .destination('Output duplicate names', CsvDestination, duplicates_path)

      agg.run
      [map_dest, dup_dest].each(&:close)
    rescue
      [map_path, duplicates_path].each { |path| File.delete path }
      raise
    end
  end

  def name_id_map_path(type)
    input_filename "#{type.to_s}_nv_name_id_map.txt"
  end

  def map_source_path(type)
    input_filename "nv_#{type.to_s}_2014.txt"
  end

  def config_hash
    {
      source_id: 65,
      state: 'nv',
      notes: 'DXT-1511: 2015 NV CRT & HSPE',
      url: 'http://www.nevadareportcard.com/di/main/assessment',
      file: 'nv/2015/output/nv.2015.1.public.charter.[level].txt',
      level: nil,
      school_type: 'public,charter'
    }
  end
end

class NameMappingAggregator < GS::ETL::Source

  def initialize
    @entities_seen = {}
  end

  def process(row)
    if same_name_entities = @entities_seen[row[:name]]
      unless same_name_entities.include? row[:id]
        same_name_entities[row[:id]] = row[:entity]
      end
    else
      @entities_seen[row[:name]] = { row[:id] => row[:entity] }
    end
    nil
  end

  def each
    @entities_seen.each do |name, hash_by_id|
      if hash_by_id.count == 1
        id, entity_level = hash_by_id.each.first
        yield({ name: name.downcase, id: id, entity_level: entity_level })
      else
        hash_by_id.each do |id, entity_leve|
          yield({ duplicate: name.downcase, id: id, entity_level: entity_level })
        end
      end
    end
  end
end

NVTestProcessor2015CRTHSPE.new("data/nv").run
