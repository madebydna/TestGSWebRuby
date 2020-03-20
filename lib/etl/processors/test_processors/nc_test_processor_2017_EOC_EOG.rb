require_relative "../test_processor"
GS::ETL::Logging.disable

class NCTestProcessor2017EOCEOG < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2017
	end

	map_subject = {
		'EOC Math I' => 5,
		'EOG Reading' => 2,
		'EOG Math' => 5,
		'EOC English 2' => 27,
    'EOC Biology' => 29,
    'EOG Science' => 25
	}

  map_gsdata_academic = {
    'EOC Math I' => 5,
    'EOG Reading' => 2,
    'EOG Math' => 5,
    'EOC English 2' => 21,
    'EOC Biology' => 22,
    'EOG Science' => 19
  }


	map_breakdown = {
		'all students' => 1,
		'asian' => 2,
		'black' => 3,
		'female' => 11,
		'eds' => 9,
		'hispanic' => 6,
		'lep' => 15,
		'male' => 12,
		'american indian' => 4,
		'swd' => 13,
		'white' => 8,
    'two or more races' => 21
	}

  map_gsdata_breakdown = {
    'all students' => 1,
    'asian' => 16,
    'black' => 17,
    'female' => 26, 
    'eds' => 23,
    'hispanic' => 19,
    'lep' => 32,
    'male' => 25,
    'american indian' => 18,
    'swd' => 27,
    'white' => 21,
    'two or more races' => 22
  }



 source('nc_2017_test_data.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:school_code] == 'NC'
       row[:entity_level] = 'state'
     elsif row[:school_code].length == 3
       row [:entity_level] = 'district'
     elsif row[:school_code].length == 6
       row[:entity_level] = 'school'
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       proficiency_band_id: 'null',
       proficiency_band_gsdata_id: 1
     })
   .transform("",MultiFieldRenamer,
     {
       school_code: :state_id
     })
   .transform('setting school_id and district_id',WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:school_id] = row[:state_id]
     elsif row[:entity_level] == 'district'
       row[:district_id] = row[:state_id]
     end
     row
   end
   .transform('pull grade out of subject', WithBlock) do |row|
     if row[:subject] =~ /Grade [0-9]$/
       row[:grade] = row[:subject][/[0-9]$/]
       row[:subject] = row[:subject].gsub(/ Grade [0-9]$/,'')
     elsif row[:subject] =~ /Grades 3-8$/ or row[:subject] =~ /Grades 5&8$/
       row[:grade] = 'All'
       row[:subject] = row[:subject].gsub(/ Grades [0-9]\S[0-9]$/,'')
     else
       row[:grade] = 'All'
     end
     row
   end
   .transform('only grade level prof',WithBlock) do |row|
     if row[:standard] == 'Grade Level Proficient'
       row[:proficiency_band] = row[:standard]
     else
       row[:proficiency_band] = 'skip'
     end
     row
   end
   .transform('delete unwanted subject rows', DeleteRows, :subject, 'All EOC Subjects','All EOG Subjects','All EOG/EOC Subjects','EOG','ACT WorkKeys','Graduation Rate','Math Course Rigor','The ACT - All Subtests','The ACT - Composite Score','The ACT - English','The ACT - Math','The ACT - Reading','The ACT - Science','The ACT - Writing')
   .transform('delete unwanted standard rows', DeleteRows, :proficiency_band, 'skip')
   .transform('assigning data types', WithBlock) do |row|
     if row[:grade] != 'All'
       row[:test_data_type] = 'EOG'
       row[:test_data_type_id] = 35
       row[:gsdata_test_data_type_id] = 274
       row[:notes] = 'DXT-2556 NC EOG 2017'
       row[:description] = 'In 2016-2017 North Carolina used End-of-Grade (EOG) tests to assess students in grades 3 through 8 in reading and math, and grades 5 and 8 in science.  The EOG is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of North Carolina.  Students must pass the grade 8 EOG test in order to graduate from high school.  The goal is for all students to score at or above the proficient level on the tests.'
     elsif row[:subject] == 'EOC Biology' || row[:subject] == 'EOC English 2' || row[:subject] == 'EOC Math I'
       row[:test_data_type] = 'EOC'
       row[:test_data_type_id] = 34
       row[:gsdata_test_data_type_id] = 273
       row[:notes] = 'DXT-2556 NC EOC 2017'
       row[:description] = 'In 2016-2017 North Carolina used End-of-Course (EOC) tests to assess high school students in Mathematics, English II, and Biology.  The EOC tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of North Carolina.  The goal is for all students to score at or above the proficient level on the tests.'
     else 
       row[:test_data_type] = 'EOG'
       row[:test_data_type_id] = 35
       row[:gsdata_test_data_type_id] = 274
       row[:notes] = 'DXT-2556 NC EOG 2017'
       row[:description] = 'In 2016-2017 North Carolina used End-of-Grade (EOG) tests to assess students in grades 3 through 8 in reading and math, and grades 5 and 8 in science.  The EOG is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of North Carolina.  Students must pass the grade 8 EOG test in order to graduate from high school.  The goal is for all students to score at or above the proficient level on the tests.'
     end
     row
   end
   .transform('transposing prof columns', Transposer, :breakdown, :value_float, :all_students_percent, :female_percent, :male_percent, :american_indian_percent, :asian_percent, :black_percent, :hispanic_percent, :two_or_more_races_percent, :white_percent, :eds_percent, :lep_percent, :swd_percent)
   .transform('fix breakdowns',WithBlock) do |row|
     row[:breakdown] = row[:breakdown].to_s.gsub('_',' ').gsub(' percent','')
     row
   end
   .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform('mapping breakdowns', HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping subjects', HashLookup, :subject, map_subject, to: :subject_id)
   .transform('mapping subjects', HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id)
   .transform('mapping counts',WithBlock) do |row|
     if row[:breakdown] == 'all students'
       row[:number_tested] = row[:all_students_denominator]
     elsif row[:breakdown] == 'asian'
       row[:number_tested] = row[:asian_denominator]
     elsif row[:breakdown] == 'black'
       row[:number_tested] = row[:black_denominator]
     elsif row[:breakdown] == 'female'
       row[:number_tested] = row[:female_denominator]
     elsif row[:breakdown] == 'eds'
       row[:number_tested] = row[:eds_denominator]
     elsif row[:breakdown] == 'hispanic'
       row[:number_tested] = row[:hispanic_denominator]
     elsif row[:breakdown] == 'lep'
       row[:number_tested] = row[:lep_denominator]
     elsif row[:breakdown] == 'male'
       row[:number_tested] = row[:male_denominator]
     elsif row[:breakdown] == 'american indian'
       row[:number_tested] = row[:american_indian_denominator]
     elsif row[:breakdown] == 'swd'
       row[:number_tested] = row[:swd_denominator]
     elsif row[:breakdown] == 'white'
       row[:number_tested] = row[:white_denominator]
     elsif row[:breakdown] == 'two or more races'
       row[:number_tested] = row[:two_or_more_races_denominator]
     end
     row
   end
   .transform('delete suppressed values', DeleteRows, :value_float, '*')
   .transform('alter <,> to load',WithBlock) do |row|
     if row[:value_float] == '<5'
       row[:value_float] = '-5'
     elsif row[:value_float] == '>95'
       row[:value_float] = '-95'
     end
     row
   end
   # .transform('delete n tested 10', DeleteRows, :number_tested, '10')
 end


def config_hash
  {
    source_id: 22,
    source_name: 'North Carolina Department of Public Instruction',
    date_valid: '2017-01-01 00:00:00',
    state:'nc',
    url: 'http://www.dpi.state.nc.us/',
    file: 'nc/2017/nc.2017.1.public.charter.[level].txt',
    level: nil,
    school_type: 'public,charter'
  }
end



end

NCTestProcessor2017EOCEOG.new(ARGV[0],max:nil,offset:nil).run
