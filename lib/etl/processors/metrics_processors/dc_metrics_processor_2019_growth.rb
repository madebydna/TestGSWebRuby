require 'set'
require_relative '../../metrics_processor'

class DCMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3502'
	end

	 map_subject_id = {
	 	'ELA' => 4,
	 	'Math' => 5
	}

	map_breakdown_id = {
	'All Report Card Students' => 1,
	'All Students' => 1,
	'American Indian/Alaskan Native' => 18,
	'Asian' => 16,
	'Black/African-American' => 17,
	'English Learners' => 32,
	'Female' => 26,
	'Hispanic/Latino of any race' => 19,
	'Male' => 25,
	'Native Hawaiian/Other Pacific Islander' => 20,
	'Not English Learners' =>  33,
	'Students with Disabilities' => 27,
	'Students without Disabilities' => 30,
	'Two or more races' => 22,
	'White' => 21
	}

	source('school_2018.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school'
	    })
	end
	source('district_2018.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'district',
	      school_id: '',
	      school_name: 'district'
	    })
	end
	source('state_2018.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'state',
	      school_id: '',
	      school_name: 'state',
	      district_id: 'state',
	      district_name: 'state'
	    })
	end
	source('school_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school'
	    })
	end
	source('district_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'district',
	      school_id: '',
	      school_name: 'district'
	    })
	end
	source('state_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'state',
	      school_id: '',
	      school_name: 'state',
	      district_id: 'state',
	      district_name: 'state'
	    })
	end

	shared do |s|
		s.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3502: DC Growth and Percentage of students meeting growth target',
			grade: 'All'
		})
		.transform('rename columns',MultiFieldRenamer, {
	    	lea_code: :district_id,
	    	lea_name: :district_name,
	    	school_code: :school_id,
	    	student_group: :breakdown,
	    	metric_n: :cohort_count,
	    	metric_score: :value,
	    	school_year: :year
		})
		.transform('create state id field', WithBlock) do |row|
			if row[:entity_type] == 'state'
				row[:state_id] = 'state'
			elsif row[:entity_type] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_type] == 'school'
				row[:state_id] = row[:school_id]
			end
			row
		end
		.transform('assign data type, data type id and subject',WithBlock) do |row|
			if row[:metric][/^Median Growth Percentile.*/]
				row[:data_type] = 'growth'
				row[:data_type_id] = 447
				if row[:metric][/^Median Growth Percentile ELA/]
					row[:subject] = 'ELA'
				elsif row[:metric][/^Median Growth Percentile - ELA/]
					row[:subject] = 'ELA'
				elsif row[:metric][/^Median Growth Percentile Math/]
					row[:subject] = 'Math'
				elsif row[:metric][/^Median Growth Percentile - Math/]
					row[:subject] = 'Math'
				else
					row[:subject] = 'Error'
				end
			elsif row[:metric][/^Growth to Proficiency.*/]
				row[:data_type] = 'percent growth'
				row[:data_type_id] = 460
				if row[:metric][/^Growth to Proficiency - ELA/]
					row[:subject] = 'ELA'
				elsif row[:metric][/^Growth to Proficiency - Math/]
					row[:subject] = 'Math'
				else
					row[:subject] = 'Error'
				end
			else
				row[:data_type] = 'skip'
				row[:data_type_id] = 'skip'
			end
			row
		end
		.transform('create subgroup skip field',WithBlock) do |row|
			if ['All Report Card Students','All Students','American Indian/Alaskan Native','Asian','Black/African-American','English Learners','Female','Hispanic/Latino of any race','Male','Native Hawaiian/Other Pacific Islander','Not English Learners','Students with Disabilities','Students without Disabilities','Two or more races','White'].include? row[:breakdown]
				row[:subgroup_skip] = 'No'
			else
				row[:subgroup_skip] = 'Yes'
			end
			row
		end
		.transform('remove unneccesary subgroups', DeleteRows, :subgroup_skip, 'Yes')
		.transform('remove unneccesary data types', DeleteRows, :data_type, 'skip')
		.transform('assign date valid', WithBlock) do |row|
			if row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			elsif row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('remove "DS" value rows', DeleteRows, :value, 'DS')
		.transform('delete "n<10" values',DeleteRows,:value,'n<10')
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	end

	def config_hash
	{
		source_id: 39,
		state: 'dc'
	}
	end
end

DCMetricsProcessor2019Growth.new(ARGV[0],max:nil).run