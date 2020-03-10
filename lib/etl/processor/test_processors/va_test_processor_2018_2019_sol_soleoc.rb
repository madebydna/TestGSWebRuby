require_relative "../test_processor"


class VATestProcessor2019SOL_EOC < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2019
	end

	map_breakdown_id={
		'All Students' => 1,
		'American Indian or Alaska Native' => 18,
		'Asian' => 16,
		'Black, not of Hispanic origin' => 17,
		'Economically Disadvantaged' => 23,
		'English Learner' => 32, 
		'F' => 26, 
		'M' => 25, 
		'Hispanic' => 19, 
		'Native Hawaiian  or Pacific Islander' => 20, 
		'Non-Hispanic, two or more races' => 22, 
		'Not Economically Disadvantaged' => 24,
		'Not English Learner' => 33, 
		'Students with Disabilities' => 27, 
		'Students without Disabilities' => 30, 
		'White, not of Hispanic origin' => 21
	}

	map_subject_id={
		'English Reading' => 80,
		'Writing' => 3,
		'Geography' => 42,
		'VA & US History' => 81,
		'World History I' => 43,
		'World History II' => 44,
		'Algebra I' => 6,
		'Algebra II' => 10,
		'Geometry' => 8,
		'Biology' => 22,
		'Chemistry' => 35,
		'Earth Science' => 36,
		'Mathematics'=> 5,
		'Science'=> 19
	}

	map_prof_band_id={
		'prof_and_above' => 1
	}
 

	source('va_sol.txt',[],col_sep:"\t") do |s|
		s.transform("Fill", Fill, {
      		test_data_type: 'SOL',
      		test_data_type_id: 293,
      		notes: 'DXT-3394 VA SOL'
      		})
      	.transform('SOL date_valid and description',WithBlock,) do |row|
				if row[:year] == '2018' 
						row[:date_valid] = '2018-01-01 00:00:00'
						row[:description] = "In 2017-2018 Virginia used the Standards of Learning (SOL) tests to assess students in reading and math in grades 3 through 8, writing in grade 8, and science in grades 5 and 8. The SOL tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Virginia. The goal is for all students to pass the tests."
				elsif row[:year] == '2019'
						row[:date_valid] = '2019-01-01 00:00:00'
						row[:description] = "In 2018-2019 Virginia used the Standards of Learning (SOL) tests to assess students in reading and math in grades 3 through 8, writing in grade 8, and science in grades 5 and 8. The SOL tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Virginia. The goal is for all students to pass the tests."
				end
				row
		end
	end

	source('va_vaeoc.txt',[],col_sep:"\t") do |s|
		s.transform("Fill", Fill, {
      		test_data_type: 'VAEOC',
      		test_data_type_id: 294,
      		notes: 'DXT-3394 VA VAEOC'
      		})
      	.transform('EOC date_valid and description',WithBlock,) do |row|
				if row[:year] == '2018' 
						row[:date_valid] = '2018-01-01 00:00:00'
						row[:description] = "In 2017-2018 Virginia used the Standards of Learning (SOL) End-of-Course tests to assess students in reading, writing, math, science and history/social science subjects at the end of each course, regardless of the student's grade level. The SOL End-of-Course tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Virginia. High school students must pass at least five SOL End-of-Course tests to graduate. The goal is for all students to pass the tests."
				elsif row[:year] == '2019'
						row[:date_valid] = '2019-01-01 00:00:00'
						row[:description] = "In 2018-2019 Virginia used the Standards of Learning (SOL) End-of-Course tests to assess students in reading, writing, math, science and history/social science subjects at the end of each course, regardless of the student's grade level. The SOL End-of-Course tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Virginia. High school students must pass at least five SOL End-of-Course tests to graduate. The goal is for all students to pass the tests."
				end
				row
		end
	end



	shared do |s|
	   s.transform('map breakdowns',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)	
		.transform('map subjects',HashLookup,:subject, map_subject_id, to: :subject_id)	
		.transform('map prof bands',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)						
	end

	def config_hash
		{
			source_id:51,
	        state: 'va'
		}		
	end

end

VATestProcessor2019SOL_EOC.new(ARGV[0],max:nil,offset:nil).run
