require 'set'
require_relative '../../metrics_processor'

class VAMetricsProcessor2019CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3410'
	end


	map_breakdown_id = {
	  'English Learners' => 32,
	  'Limited English Proficient Students' => 32,
	  'All Students' => 1, 
	  'Female' => 26, 
	  'Male' => 25, 
	  'American Indian' => 18, 
	  'Asian' => 16, 
	  'Black' => 17, 
	  'Native Hawaiian' => 20, 
	  'Hispanic' => 19, 
	  'Multiple Races' => 22, 
	  '2 or More' => 22, 
	  'White' => 21,
	  'Students with Disabilities' => 27, 
	  'Economically Disadvantaged' => 23
	}

	map_subject_id = {
		'NA' => 0
	}

	map_data_type_id = {
		'Grad Rate' => 443,
		'College Enrollment' => 414,
		'College Persistance' => 409
	}



	source('va_2018_2019.txt',[],col_sep:"\t") 


	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3410: VA CSA'
		})
		.transform('Create date_valid', WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map datatype ids',HashLookup,:data_type, map_data_type_id,to: :data_type_id)
	end

	def config_hash
	{
		source_id: 51,
		state: 'va'
	}
	end
end

VAMetricsProcessor2019CollegeReadiness.new(ARGV[0],max:nil).run