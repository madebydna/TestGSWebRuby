require_relative "../test_processor"

class TXTestProcessor2018STAAR < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  key_map_bd = {
    'all students' => 1,
    'male students' => 25,
    'female students' => 26,
    'hispanic latino students' => 19,
    'american indian or alaskan native students' => 18,
    'asian students' => 7,
    'black african american students' => 17,
    'native hawaiian pacific islander students' => 20,
    'white students' => 21,
    'two or more races students' => 22,
    'econ disadv students codes  1 2 9' => 23,
    'not econ disadv students' => 24,
    'current lep students' => 32,
    'special ed students' => 27,
    'not special ed students' => 30
  }

  key_map_sub = {
    'mathematics' => 5,
    'reading' => 2,
    'science' => 19,
    'social_studies' => 18,
    'writing' => 3,
    'us_history' => 23,
    'biology'=> 22,
    'algebra_i' => 6,
    'english_i' => 17,
    'english_ii' => 21
  }

  key_map_pro = {
    :"meets" => 1
  }

  source("tx_staar_2018_state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'state',
      })
  end
  source("tx_staar_2018_district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      })
  end
  source("tx_staar_2018_school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      })
  end

  
  shared do |s|
    s.transform("delete unnecessary breakdown rows",DeleteRows, :breakdown, 'not migrant students','not gifted talented students','no sex info students','no migrant info students','no lep info students',
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
      test_data_type: 'STAAR',
      test_data_type_id: 272, 
      year: 2018,
      notes: 'DXT-2833: TX STAAR',
      date_valid: '2018-01-01 00:00:00',
      description: 'In 2017-2018, the State of Texas Assessments of Academic Readiness (STAAR) was used to test students in reading and math in grades 3 through 8; in writing in grades 4 and 7; in science in grades 5 and 8; in social studies in grade 8; and end-of-course assessments for English I and II, Algebra I, Biology and US History. STAAR is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Texas. The goal is for all students to score at or above the state standard.'
    })
    .transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value,
       :"meets"
       )
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_type]=='school' 
          row[:state_id] = row[:school_id].rjust(9,'0')
      elsif row[:entity_type]=='district'
          row[:state_id] = row[:district_id].rjust(6,'0')
      end
      row
    end
    .transform('Fill missing ids and names with entity_level', WithBlock) do |row|
      [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
        row[col] ||= row[:entity_type]
      end
      row
    end
  end

  def config_hash
    {
        source_id:48,
        state: 'tx'
    }
  end
end

TXTestProcessor2018STAAR.new(ARGV[0], max: nil).run