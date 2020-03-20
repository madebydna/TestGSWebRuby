require_relative "../test_processor"

class WYTestProcessor2019PAWSTOPP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2019
	end

	map_subject = {
		'Math' => 5,
		'Reading' => 2,
		'Science' => 19,
		'English Language Arts (ELA)' => 4
	}

	map_prof_band = {
		'Percent_Proficient_and_Advanced' => 1,
		'Percent_Below_Basic' => 64,
		'Percent_Basic' => 65,
		'Percent_Proficient' => 66,
		'Percent_Advanced' => 67
	}

	map_breakdown = {
		'All Students' => 1,
		'Hispanic' => 19,
		'American Indian/Alaska Native' => 18,
		'Asian' => 16,
		'Black' => 17,
		'Native Hawaiian/Pacific Islander' => 20,
		'White' => 21,
		'Two or More Races' => 22,
		'Female' => 26,
		'Male' => 25,
		'English Language Learner' => 32,
		'Non-English Language Learner' => 33,
		'Free/Reduced Lunch' => 23,
		'Non-Free/Reduced Lunch' => 24,
		'Individual Education Plan (IEP)' => 27,
		'Non-Individual Education Plan (non-IEP)' => 30

	}

	source('wy_test.txt',[],col_sep:"\t") do |s|
	   s.transform('map subject id',HashLookup, :subject, map_subject, to: :subject_id)
		.transform('map breakdown id',HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
		.transform('map prof band id',HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
        .transform('Add test description', WithBlock) do |row|
            if row[:year] == '2017'
               row[:date_valid] = '2017-01-01 00:00:00'
               row[:description] = 'In the 2016-2017 school year, Wyoming administered the Proficiency Assessments for Wyoming Students (PAWS). Students in grades 3 through 8, and 11 were tested in reading and math. Students in grades 4, 8, and 11 also took the science portion of the PAWS test. PAWS tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Wyoming. The goal is for all students to score at or above the proficient level.'
            elsif row[:year] == '2018'
           	   row[:date_valid] = '2018-01-01 00:00:00'
               row[:description] = 'In 2017-18, Wyoming administered the Wyoming Test of Proficiency and Progress (WY-TOPP).The WY-TOPP is a system of online assessments that are given to students in grades 3-10 in English language arts and mathematics, and given to students in grades 4, 8, and 10 in science. The goal is for all students to score at or above the proficient level.'
            elsif row[:year] == '2019'
           	   row[:date_valid] = '2019-01-01 00:00:00'
           	   row[:description] = 'In 2018-19, Wyoming administered the Wyoming Test of Proficiency and Progress (WY-TOPP).The WY-TOPP is a system of online assessments that are given to students in grades 3-10 in English language arts and mathematics, and given to students in grades 4, 8, and 10 in science. The goal is for all students to score at or above the proficient level.'          
           end
           row
        end 
        .transform('Add test details', WithBlock) do |row|
            if row[:test_type] == 'paws'
              row[:notes] = 'DXT-3135: WY PAWS'
              row[:test_data_type] = 'PAWS'
              row[:test_data_type_id] = 194
            elsif row[:test_type] == 'topp'
              row[:notes] = 'DXT-3135: WY TOPP'
              row[:test_data_type] = 'WY TOPP'
              row[:test_data_type_id] = 362     
           end
           row
        end 
	end

	def config_hash
		{
			source_id:55,
			state:'wy'
		}
	end
end

WYTestProcessor2019PAWSTOPP.new(ARGV[0],max:nil).run