require_relative '../../metrics_processor'

class MAMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3469'
	end

	map_breakdown_id = {
		'African American/Black' => 17,
		'African American' => 17,
		'All Students' => 1,
		'American Indian or Alaska Native' => 18,
		'Native American' => 18,
		'Asian' => 16,
		'Economically Disadvantaged' => 23,
		'English Language Learner (EL)' => 32,
		'Female' => 26,
		'Male' => 25,
		'Hispanic/Latino' => 19,
		'Multi-Race (non-Hispanic/Latino)' => 22,
		'Hawaiian/Pacific Islander' => 20,
		'Native Hawaiian or Pacific Islander' => 20,
		'Non-Economically Disadvantaged' => 24,
		'Students with Disabilities' => 27,
		'White' => 21
	}

	map_subject_id = {
		'ELA' => 4,
		'MAT' => 5
	}

	source('2018achievement-growth-Legacy-district.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00'
	    })
	    .transform('assign entity_type and state_ids',WithBlock) do |row|
			if row[:districtcode] == '00000000'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'district'
				row[:state_id] = row[:districtcode].to_s[0,4]
			end
			row
		end
	end

	source('2018achievement-growth-Legacy-school.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00',
	      entity_type: 'school'
	    })
	    .transform('assign state_ids',WithBlock) do |row|
			row[:state_id] = row[:schoolcode].rjust(8,'0')
			row
		end
	end

	source('2018achievement-growth-NextGen-district.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00'
	    })
	    .transform('assign entity_type and state_ids',WithBlock) do |row|
			if row[:districtcode] == '00000000'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'district'
				row[:state_id] = row[:districtcode].to_s[0,4]
			end
			row
		end
	end

	source('2018achievement-growth-NextGen-school.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00',
	      entity_type: 'school'
	    })
	    .transform('assign state_ids',WithBlock) do |row|
			row[:state_id] = row[:schoolcode].rjust(8,'0')
			row
		end
	end

	source('2019achievement-growth-NextGen-district.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2019,
	      date_valid: '2019-01-01 00:00:00'
	    })
	    .transform('assign entity_type and state_ids',WithBlock) do |row|
			if row[:org_code] == '00000000'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'district'
				row[:state_id] = row[:org_code].to_s[0,4]
			end
			row
		end
	end

	source('2019achievement-growth-NextGen-school.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2019,
	      date_valid: '2019-01-01 00:00:00',
	      entity_type: 'school'
	    })
	    .transform('assign state_ids',WithBlock) do |row|
			row[:state_id] = row[:schoolcode].rjust(8,'0')
			row
		end
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown,
			schoolcode: :school_id,
			schoolname: :school_name,
			districtcode: :district_id,
			districtname: :district_name,
			sgp_incl: :cohort_count,
			mean_sgp: :value
		})
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'EL and Former EL','Ever EL','Former EL','Foster','High Needs', 'Homeless', 'Migrant', 'Military', 'Non-Title I', 'Title I')
		.transform('delete unwanted subject rows',DeleteRows,:subject,'ALL_STE','BIO','CHE','G10_SCI','PHY', 'STE', 'TEC')
		.transform('delete unwanted grade rows',DeleteRows,:grade,'03', '3-8', '5&8', 'AL', 'HS')
		.transform('delete suppressed rows',DeleteRows,:value, " ")
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			data_type_id: 469,
			notes: 'DXT-3469: MA Growth'
		})
		.transform('format grades',WithBlock) do |row|
	    	if row[:grade] == '10'
	    		row[:grade] = row[:grade]
	    	else
	    		row[:grade] = row[:grade].tr('0','')
	    	end
	    	row
	    end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map breakdown ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	def config_hash
	{
		source_id: 25,
        state: 'ma'
	}
	end
end

MAMetricsProcessor2019Growth.new(ARGV[0],max:nil).run