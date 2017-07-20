require_relative "../test_processor"

class ORTestProcessor2016SBACOAKS < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  key_map_bd = {
    'American Indian/Alaskan Native' => 4,
    'Asian' => 2,
    'Black/African American' => 3,
    'Econo. Disadvantaged' => 9,
    'Female' => 11,
    'Hispanic/Latino' => 6,
    'Limited English Proficient (LEP)' => 15,
    'Male' => 12,
    'Multi-Racial' => 21,
    'Pacific Islander'=> 7,
    'Students with Disabilities (SWD)' => 13,
    'Total Population (All Students)' => 1,
    'White' => 8,
    'Asian/Pacific Islander' => 22
  }

  key_map_sub = {
    'English Language Arts' => 4,
    'Mathematics' => 5,
    'Science' => 25
  }

  sbac_key_map_pro = {
    :"percent_level_1" => 34,
    :"percent_level_2" => 35,
    :"percent_level_3" => 36,
    :"percent_level_4" => 37,
    :"percent_level_3_or_4" => 'null',
  }

  oaks_key_map_pro = {
      :"percent_very_low" => 38,
      :"percent_low" => 39,
      :"percent_nearly_meets" => 40,
      :"percent_meets" => 41,
      :"percent_exceeds" => 42,
      :"percent_meets_or_exceeds" => 'null'
  }

  source("sbac_332017_w.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'sbac',
      test_data_type_id: 318
      })
      .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percent_level_1",
       :"percent_level_2",
       :"percent_level_3",
       :"percent_level_4",
       :"percent_level_3_or_4"
      )
      .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, sbac_key_map_pro, to: :proficiency_band_id)
  end
  source("oaks_science_372017_w.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
        test_data_type: 'oaks',
        test_data_type_id: 60
    })
     .transform('Transpose value columns', Transposer,
      :proficiency_band,
      :value_float,
      :"percent_very_low",
      :"percent_low",
      :"percent_nearly_meets",
      :"percent_meets",
      :"percent_exceeds",
      :"percent_meets_or_exceeds"
     )
     .transform("Adding column_id from proficiency band", HashLookup, :proficiency_band, oaks_key_map_pro, to: :proficiency_band_id)
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        districtid: :district_id,
        district: :district_name,
        schoolid: :school_id,
        school: :school_name,
        studentgroup: :breakdown,
        gradelevel: :grade,
        n_tested: :number_tested
      })
    .transform("Remove suppressed bands", DeleteRows, :value_float, '-')
    .transform("Remove weird breakdowns", DeleteRows, :breakdown, 'Extended Assessment', 'Indian Education', 'Migrant Education', 'SWD with Accommodations','Talented and Gifted (TAG)')
    .transform("Delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2016
    })
    .transform("Update prof null", WithBlock,) do |row|
      if row[:value_float] == '> 95.0%'
        row[:value_float] = '-95'
        row[:number_tested] = ''
      elsif row[:value_float] == '< 5.0%'
        row[:value_float] = '-5'
        row[:number_tested] = ''
      end
      row
    end
    .transform("Adding column breakdown_id from breadown", HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Edit grade", WithBlock,) do |row|
      if row[:grade] == 'All Grades'
        row[:grade] = 'All'
      else
        row[:grade] = row[:grade].gsub(/[^\d]/, '')
      end
      row
    end
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id] == 'district'
        row[:entity_level] ='district'
        row[:state_id] = row[:district_id].rjust(14,'0')
      elsif row[:school_id] == 'state'
        row[:entity_level] ='state'
      else
        row[:entity_level] ='school'
        row[:district_id] = row[:district_id].rjust(14,'0')
        row[:state_id] = row[:school_id].rjust(20,'0')
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
        source_id: 31,
        state: 'or',
        notes: 'DXT-2032: OR SBAC and OAKS Science 2016 test load.',
        url: 'http://www.ode.state.or.us',
        file: 'or/2016/output/or.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

ORTestProcessor2016SBACOAKS.new(ARGV[0], max: nil).run
