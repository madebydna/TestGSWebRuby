require_relative "../test_processor"

class TXTestProcessor2017STAAR < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  key_map_bd = {
    'all students' => 1,
    'male students' => 12,
    'female students' => 11,
    'hispanic latino students' => 6,
    'american indian or alaskan native students' => 4,
    'asian students' => 2,
    'black african american students' => 3,
    'native hawaiian pacific islander students' => 112,
    'white students' => 8,
    'two or more races students' => 21,
    'econ disadv students codes  1 2 9' => 9,
    'not econ disadv students' => 10,
    'current lep students' => 15,
    'special ed students' => 13,
    'not special ed students' => 14
  }

  key_map_sub = {
    'mathematics' => 5,
    'reading' => 2,
    'science' => 25,
    'social_studies' =>24,
    'writing' => 3,
    'us_history' => 30,
    'biology'=> 29,
    'algebra_i' => 7,
    'english_i' => 19,
    'english_ii' => 27
  }

  key_map_pro = {
    :"meets" => 'null'
  }

  # source("tx_staar_2017_state.txt",[], col_sep: "\t") do |s|
  #   s.transform('Fill missing default fields', Fill, {
  #     entity_level: 'state',
  #     })
  # end
  # source("tx_staar_2017_district.txt",[], col_sep: "\t") do |s|
  #   s.transform('Fill missing default fields', Fill, {
  #     entity_level: 'district',
  #     })
  # end
  source("tx_staar_2017_school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      })
  end

  
  shared do |s|
    s.transform("delete no need breakdown rows",DeleteRows, :breakdown, 'not migrant students','not gifted talented students','no sex info students','no migrant info students','no lep info students',
      'no info econ students','no ethnicity info students','migrant students','gifted talented students','first year monitored students','bilingual students  codes  2 3 4 5','free meals students',
      'reduced price meals students','other econ disadvantaged students','other non lep students','second year monitored students',
      'title i participant students codes  6 7 9','not title i participant students codes  0 8','nonparticipant  not previous participant students ', 'schoolwide program participant students',
      'targeted assistance participant students','nonparticipant  previous participant  students','homeless participant at non title i schools students','no title i info students',
      'no migrant info students','not bilingual students','transitional bilingual early exit students','transitional bilingual late exit students','dual language immersion two way students',
      'dual language immersion one way students','no info bilingual students','esl students codes  2 3','not esl students','esl content based students','esl pull out students',
      'no info esl students','either bilingual or esl','neither bilingual nor esl  codes  biling 0   esl 0','no info for both and or either bilingual esl','no info special ed students',
      'no info gifted talented students','at risk students','not at risk students','no info at risk students','career tech students  codes  1 2 3','not career tech students',
      'career tech elective students','career tech coherent sequence students','career tech tech prep students','no info career tech students')
    .transform("delete rows where number tested is less than 10",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
    .transform('Fill missing default fields', Fill, {
      test_data_type: 'staar',
      test_data_type_id: 194, 
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2017,
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :"meets"
       )
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_level]=='school' 
          row[:state_id] = row[:school_id].rjust(9,'0')
      elsif row[:entity_level]=='district'
          row[:state_id] = row[:district_id].rjust(6,'0')
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
        source_id: 6,
        state: 'tx',
        notes: 'DXT-2442: TX, STAAR',
        url: 'http://www.tea.state.tx.us/',
        file: 'tx/2017/output/tx.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

TXTestProcessor2017STAAR.new(ARGV[0], max: nil).run