require_relative '../../metrics_processor'

class INMetricsProcessor2019CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3407'
	end

	map_subject_id = {
	#SAT and ACT
	'Composite' => 1,
	'Math' => 5,
	'Reading' => 2,
	#ACT
	'English' => 17,
	'Science' => 19,
	'NA' => 0
	}

map_breakdown_id = {
	'All Students' => 1,
	'Total' => 1,
	'Asian' => 16,
	'Black' => 17,
	'American Indian' => 18,
	'Paid Meals' => 24,
	'Free/Reduced Price Meals' => 23,
	'Free/Reduced Meals' => 23,
	'General Education' => 30,
	'Special Education' => 27,
	'Non-English Language Learner' => 33,
	'English Language Learner' => 32,
	'Female' => 26,
	'Male' => 25,
	'Native Hawaiian or Other Pacific Islander' => 20,
	'Hispanic' => 19,
	'Multiracial' => 22,
	'White' => 21
	}

	source('state_grad.txt',[],col_sep:"\t")
	source('district_grad.txt',[],col_sep:"\t")
	source('public_school_grad.txt',[],col_sep:"\t")
	source('private_school_grad.txt',[],col_sep:"\t")
	source('sat_school.txt',[],col_sep:"\t")
	source('sat_district.txt',[],col_sep:"\t")
	source('act_school.txt',[],col_sep:"\t")
	source('act_district.txt',[],col_sep:"\t")

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3407: IN College Readiness'
		})
		.transform('Assign date_valid based on year',WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			end
			row
		end
		.transform('Adjust state_ids',WithBlock) do |row|
			if row[:state_id] == '5469' && row[:entity_type] == 'school'
				row[:state_id] = '5462'
			elsif row[:state_id] == '5473' && row[:entity_type] == 'school'
				row[:state_id] = '5474'
			elsif row[:state_id] == '5487' && row[:entity_type] == 'school'
				row[:state_id] = '5492'
			elsif row[:state_id] == '5643' && row[:entity_type] == 'school'
				row[:state_id] = '5644'
			end
			row
		end
		.transform('remove None and NA values', DeleteRows, :value, 'NA')
		.transform('Multiple grad, act and sat participation values by 100, format to 6 digits', WithBlock) do |row|
			if ['443','396','439'].include? row[:data_type_id]
				row[:value] = row[:value].to_f * 100
			else
				row[:value] == row[:value]
			end
			row[:value] = sprintf('%.6f', row[:value]).to_f.to_s
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
	end

	def config_hash
	{
		source_id: 18,
		state: 'in'
	}
	end
end

INMetricsProcessor2019CollegeReadiness.new(ARGV[0],max:nil).run