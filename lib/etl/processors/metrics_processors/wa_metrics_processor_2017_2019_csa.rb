require 'set'
require_relative '../../metrics_processor'

class WAMetricsProcessor2019CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3411'
	end


	map_breakdown_id = {
	  'All Students' => 1, 
	  'All' => 1,
	  'American Indian or Alaska Native' => 18, 
	  'American Indian / Alaskan Native' => 18, 
	  'American Indian/ Alaskan Native' => 18,
	  'Asian' => 16, 
	  'Black or African American' => 17, 
	  'Black / African American' => 17, 
	  'Black/ African American' => 17,
	  'English Language Learners' => 32,
	  'Female' => 26, 
	  'FRPL' => 23,
	  'Gender X' => 72,
	  'Hispanic/ Latino of any race(s)' => 19, 
	  'Low-Income' => 23,
	  'Male' => 25, 
	  'Multiple Races (Details Unknown)' => 22, 
	  'Native Hawaiian or Other Pacific Islander' => 20, 
	  'Native Hawaiian / Other Pacific Islander' => 20, 
	  'Native Hawaiian/ Other Pacific Islander' => 20,
	  'Native Hawaiian and Other Pacific Islander' => 20,
	  'Non-English Language Learners' => 33,
	  'Non-Low Income' => 24,
	  'Not FRPL' => 24,
	  'Not Special Education' => 30,
	  'Spanish/Hispanic/Latino' => 19,
	  'Special Education' => 27,
	  'Students with Disabilities' => 27, 
	  'Students without Disabilities' => 30,
	  'Two or More Races' => 22, 
	  'White' => 21

	}

	map_subject_id = {
		'NA' => 0,
		'Any' => 89, 
		'Both' => 1,
		'Math' => 5,
		'English' => 17
	}

	map_data_type_id = {
		'Grad Rate' => 443,
		'One Year Enrollment' => 474,
		'2 Year Persistence' => 489,
		'4 Year Persistence' => 488,
	    '2 Year Remediation' => 508,
		'4 Year Remediation' => 509,
	}



	source('wa_2017_2019.txt',[],col_sep:"\t") 


	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3411: WA CSA'
		})
		.transform('Create date_valid', WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2017'
				row[:date_valid] = '2017-01-01 00:00:00'
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map datatype ids',HashLookup,:data_type, map_data_type_id,to: :data_type_id)
		.transform('Round value', WithBlock) do |row|
			row[:value] = row[:value].to_f.round(6)
			row
		end
	end

	def config_hash
	{
		source_id: 52,
		state: 'wa'
	}
	end
end

WAMetricsProcessor2019CollegeReadiness.new(ARGV[0],max:nil).run