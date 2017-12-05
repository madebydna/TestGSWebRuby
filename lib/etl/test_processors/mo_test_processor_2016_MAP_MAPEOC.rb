require_relative "../test_processor"

class MOTestProcessor2016MAP_MAPEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  key_map_bd = {
    'Amer. Indian or Alaska Native' => 4,
    'Asian/Pacific Islander' => 22,
    'Black (not Hispanic)' => 3,
    'Hispanic' => 6,
    'Multiracial' => 21,
    'White (not Hispanic)' => 8,
    'LEP/ELL Students' => 15,
    'Map Free and Reduced Lunch' => 9,
    'Non Free and Reduced Lunch' => 10,
    'Total' => 1
  }

  key_map_sub = {
   'Eng. Language Arts' => 4,
   'Mathematics' => 5,
   'Science' => 25,
   'E1' => 19,
   'E2' => 27,
   'A1' => 7,
   'A2' => 11,
   'AH' => 30,
   'B1' => 29,
   'PS' => 31,
   'GE' => 9,
   'GV' => 71,
  }
  
  source("state_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
  })
  end

  source("district_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
       entity_level: 'district',
  })
  end

  source("school_cal.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
       entity_level: 'school',
  })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        pro_null: :value_float
      })
    .transform('Fill missing default fields', Fill, {
        entity_type: 'public_charter',
        proficiency_band: 'null',
        proficiency_band_id: 'null',
        level_code: 'e,m,h'
    })
    .transform("delete grade 11 data",DeleteRows, :grade, '11')
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
          row[:state_id] = row[:district_id]
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:school_id]
      end
      row
    end
    .transform("Lowercase/capitalize column",WithBlock) do |row|
      if row[:grade] == 'all'
        row[:test_data_type] = 'map eoc'
        row[:test_data_type_id] = 145
      else
        row[:test_data_type] = 'map'
        row[:test_data_type_id] = 28
      end
      row
    end
    .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
      [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
        row[col] ||= row[:entity_level]
      end
      row
    end
  end

  def config_hash
    {
        source_id: 12,
        state: 'mo',
        notes: 'DXT-2030: MO MAP and MAP EOC 2016 test load.',
        url: 'http://www.dese.state.mo.us/',
        file: 'mo/2016/output/mo.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

MOTestProcessor2016MAP_MAPEOC.new(ARGV[0], max: nil).run
