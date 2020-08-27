require_relative '../../metrics_processor'

class ALMetricsProcessor2018CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3603'
	end

	map_breakdown_id = {
		'all_students' => 1,
		'asian' => 16,
		'black' => 17,
		'female' => 26,
		'frl' => 23,
		'gen_ed' => 30,
		'hispanic' => 19,
		'lep' => 32,
		'male' => 25,
		'multiracial'=> 22,
		'native_american' => 18,
		'pacific_islander' => 37,
		'swd' => 27,
		'white' => 21
	}

	map_subject_id = {
		'Math' => 5,
		'English' => 17,
		'Composite Subject' => 1,
		'Any Subject' => 89,
	}

	source('ACTCollegeReady.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'All',
			data_type: 'ACT percent college ready',
			data_type_id: 454,
			date_valid: '2018-01-01 00:00:00',
			year: '2018',
			subject: 'Composite Subject',
			subject_id: 1
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			act_denom: :cohort_count,
			act_percent_cr: :value
		})
	    .transform('create state ids and assign entity_type', WithBlock) do |row|
			if row[:system_code] == '0'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:system_code] != '0' and row[:school_code] == '0'
				row[:entity_type] = 'district'
				row[:state_id] = row[:system_code].rjust(3,'0')
				row[:district_name] = row[:system_name]
			elsif row[:school_code] != '0'
				row[:entity_type] = 'school'
				row[:state_id] = row[:system_code].rjust(3,'0') + row[:school_code].rjust(4,'0')
				row[:school_name] = row[:school_name]
			else
				row[:entity_type] = 'Error'
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
	end

	source('GraduationRate.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'NA',
			data_type: 'grad rate',
			data_type_id: 443,
			date_valid: '2018-01-01 00:00:00',
			year: '2018',
			subject: 'Not Applicable',
			subject_id: 0
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			grad_denom: :cohort_count,
			grad_rate: :value
		})
	    .transform('create state ids and assign entity_type', WithBlock) do |row|
			if row[:system_code] == '0'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:system_code] != '0' and row[:school_code] == '0'
				row[:entity_type] = 'district'
				row[:state_id] = row[:system_code].rjust(3,'0')
				row[:district_name] = row[:system_name]
			elsif row[:school_code] != '0'
				row[:entity_type] = 'school'
				row[:state_id] = row[:system_code].rjust(3,'0') + row[:school_code].rjust(4,'0')
			else
				row[:entity_type] = 'Error'
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
	end

	source('CollegeEnrollment.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'NA',
			date_valid: '2017-01-01 00:00:00',
			year: '2017',
			subject: 'Not Applicable',
			subject_id: 0,
			breakdown: 'All Students',
			breakdown_id: 1
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			cohort_count_nocommas: :cohort_count,
			state_id_x: :school_state_id,
			state_id_y: :district_state_id,
			entity_level: :entity_type
		})
	    .transform('assign state_id and entity name', WithBlock) do |row|
			if row[:entity_type] == 'state'
				row[:state_id] = 'state'
			elsif row[:entity_type] == 'district'
				row[:state_id] = row[:district_state_id].to_i.to_s.rjust(3,'0')
				row[:district_name] = row[:entity_name]
			elsif row[:entity_type] == 'school'
				row[:state_id] = row[:school_state_id].to_i.to_s.rjust(7,'0')
				row[:school_name] = row[:entity_name]
			else
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('setting data_type, data_type_id, and fixing percents for overall enrollment rate',WithBlock) do |row|
			if row[:variable][/non_enroll_rate/]
				row[:data_type] = 'overall enrollment'
				row[:data_type_id] = 414
				row[:value] = '%.2f' % (100-row[:value].to_f)
			elsif row[:variable][/2yr_enroll_rate/]
				row[:data_type] = 'enrollment in 2 yr IHEs'
				row[:data_type_id] = 425
				row[:value] = row[:value].to_f
			elsif row[:variable][/4yr_enroll_rate/]
				row[:data_type] = 'enrollment in 4 yr IHEs'
				row[:data_type_id] = 429
				row[:value] = row[:value].to_f
			end
			row
		end
	end

	shared do |s|
		s.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3603: AL CSA'
		})
		.transform('fix cohort counts', WithBlock) do |row|
			unless row[:cohort_count].nil?
				row[:cohort_count] = row[:cohort_count].to_i
			end
		    row
		end
	end

	def config_hash
	{
		source_id: 4,
        state: 'al'
	}
	end
end

ALMetricsProcessor2018CSA.new(ARGV[0],max:nil).run