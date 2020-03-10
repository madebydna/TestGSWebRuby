require_relative "../test_processor"

class CATestProcessor2016CAASPPCST < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  key_map_bd = {
    '1' => 1,
    '3' => 12,
    '4' => 11,
    '6' => 31,
    '31' => 9,
    '111' => 10,
    '74' => 3,
    '75' => 4,
    '76' => 2,
    '77' => 5,
    '78' => 6,
    '79' => 112,
    '80' => 8,
    '99' => 14,
    '128' => 13,
    '144' => 21,
    '160' => 15,
    '180' => 16,
    '90' => 88,
    '91' => 89,
    '92' => 92,
    '93' => 93,
    '94' => 94,
    '121' => 119,
    '7' => 134,
    '8' => 135,
  }

  key_map_sub = {
    '1' => 4,
    '2' => 5,
    '32' => 25
  }

  key_map_pro = {
    :"percentage_standard_exceeded" => 25,
    :"percentage_standard_met" => 24,
    :"percentage_standard_nearly_met" => 23,
    :"percentage_standard_not_met" => 22,
    :"percentage_standard_met_and_above" => 'null',
  }

  source("ca_2016_ela_math_1.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'caaspp',
      test_data_type_id: 236
    })
      .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percentage_standard_exceeded",
       :"percentage_standard_met",
       :"percentage_standard_nearly_met",
       :"percentage_standard_not_met",
       :"percentage_standard_met_and_above"
       )
  end
  source("ca_2016_ela_math_2.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'caaspp',
      test_data_type_id: 236
  })
      .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percentage_standard_exceeded",
       :"percentage_standard_met",
       :"percentage_standard_nearly_met",
       :"percentage_standard_not_met",
       :"percentage_standard_met_and_above"
       )    
  end
  source("ca_2016_ela_math_3.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'caaspp',
      test_data_type_id: 236
  })
      .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"percentage_standard_exceeded",
       :"percentage_standard_met",
       :"percentage_standard_nearly_met",
       :"percentage_standard_not_met",
       :"percentage_standard_met_and_above"
       )
   end
  source("ca_2016_science.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      test_data_type: 'cst',
      test_data_type_id: 18,
      proficiency_band: 'null',
      proficiency_band_id: 'null'
    })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        district_code: :district_id,
        school_code: :school_id,
        school: :school_name,
        subgroup_id: :breakdown,
        test_id: :subject,
        students_with_scores: :number_tested,
        percentage_at_or_above_proficient: :value_float
      })
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2016
    })
    .transform("delete rows where number tested is less than 10 ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:school_id] == '0000000'
        if row[:district_id] == '0000000'
          row[:entity_level] = 'state'
        else 
          row[:entity_level] ='district'
          row[:state_id] = row[:district_id]
        end
      else
        row[:entity_level] ='school'
        row[:state_id] = row[:district_id]+row[:school_id]
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
        source_id: 7,
        state: 'ca',
        notes: 'DXT-1783: CA CAASPP and CST Science 2016 test load.',
        url: 'http://caaspp.cde.ca.gov/sb2016/ResearchFileList',
        file: 'ca/2016/output/ca.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

CATestProcessor2016CAASPPCST.new(ARGV[0], max: nil).run
