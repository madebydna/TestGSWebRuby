require_relative "../../test_processor"

class NCTestProcessor20182019EOCEOG < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2019
    @ticket_n = 'DXT-3427'
	end

	map_subject = {
    'BI' => 22, #Biology
    'E2' => 21, #English 2
    'M1' => 84, #Integrated Math 1
    'M3' => 85, #Integrated Math 3
    'MA' => 5, #Math
    'RD' => 2, #Reading
    'SC' => 19 #Science
	}


	map_breakdown = {
		'ALL' => 1,
		'ASIA' => 16,
		'BLCK' => 17,
		'FEM' => 26,
		'EDS' => 23,
		'HISP' => 19,
		'ELS' => 32,
		'MALE' => 25,
		'AMIN' => 18,
		'SWD' => 27,
		'WHTE' => 21,
    'MULT' => 22,
    'NEDS' => 24, 
    'NSWD' => 30
	}

  map_prof = {
    'lev1_pct' => 18,
    'lev2_pct' => 19, 
    'lev3_pct' => 20, 
    'lev4_pct' => 21, 
    'lev5_pct' => 22, 
    'glp_pct' => 1, #glp_pct
    'mnot_pct' => 161, #special mappings for math subjects in 2019 (MA, M1, M3)
    'm_lev3_pct' => 162, 
    'm_lev4_pct' => 163, 
    'm_lev5_pct' => 164, 
    'm_glp_pct' => 1 #glp_pct for math subjects in 2019
  }

  # map_math_prof = {
  #   'mnot_pct' => 161,
  #   'm_lev3_pct' => 162, 
  #   'm_lev4_pct' => 163, 
  #   'm_lev5_pct' => 164, 
  #   'm_prof_and_above' => 1
  # }

 source('nc_2018_2019.txt',[],col_sep:"\t")


  shared do |s|
   s.transform('Assign descriptions, notes and data_type_ids', WithBlock) do |row|
     if row[:data_type] == 'EOG'
       row[:data_type_id] = 274
       row[:notes] = 'DXT-3427 NC EOG'
        if row[:year] == '2018'
          row[:description] = 'In 2017-2018, North Carolina used End-of-Grade (EOG) tests to assess students in grades 3 through 8 in reading and math, and grades 5 and 8 in science.  The EOG is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of North Carolina.  Students must pass the grade 8 EOG test in order to graduate from high school.  The goal is for all students to score at or above the proficient level on the tests.'
          row[:date_valid] ='2018-01-01 00:00:00'
        elsif row[:year] =='2019'
          row[:description] = 'In 2018-2019, North Carolina used End-of-Grade (EOG) tests to assess students in grades 3 through 8 in reading and math, and grades 5 and 8 in science.  The EOG is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of North Carolina.  Students must pass the grade 8 EOG test in order to graduate from high school.  The goal is for all students to score at or above the proficient level on the tests.'
          row[:date_valid] ='2019-01-01 00:00:00'
        end
     elsif row[:data_type] == 'EOC' 
       row[:data_type_id] = 273
       row[:notes] = 'DXT-3427 NC EOC'
        if row[:year]=='2018'
          row[:description] = 'In 2017-2018 North Carolina used End-of-Course (EOC) tests to assess high school students in Mathematics, English II, and Biology.  The EOC tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of North Carolina.  The goal is for all students to score at or above the proficient level on the tests.'
          row[:date_valid] ='2018-01-01 00:00:00'
        elsif row[:year]=='2019'
          row[:description] = 'In 2018-2019 North Carolina used End-of-Course (EOC) tests to assess high school students in Mathematics I and III, English II, and Biology.  The EOC tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of North Carolina.  The goal is for all students to score at or above the proficient level on the tests.'
          row[:date_valid] ='2019-01-01 00:00:00'
        end
     end
     row
   end
   .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform('mapping subjects', HashLookup, :subject, map_subject, to: :subject_id)
   .transform('mapping profs', HashLookup, :proficiency_band, map_prof, to: :proficiency_band_id)
 end


  def config_hash
    {
      source_id: 37,
      state:'nc'
    }
  end
end


NCTestProcessor20182019EOCEOG.new(ARGV[0],max:nil,offset:nil).run
