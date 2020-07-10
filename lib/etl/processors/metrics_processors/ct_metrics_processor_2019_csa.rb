require_relative '../../metrics_processor'

class CTMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3387'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'American Indian or Alaska Native' => 18,
		'Indian or Alaska Native' => 18,
		'Asian' => 16,
		'Black or African American' => 17,
		'Black' => 17,
		'Economically Disadvantaged' => 23,
		'Eligible for Free or Reduced- Price Meals' => 23,
		'FRL' => 23,
		'Female' => 26,
		'Hispanic/Latino of any race' => 19,
		'Hispanic or Latino' => 19,
		'Hispanic' => 19,
		'English Language Learner' => 32,
		'English Language Learners' => 32,
		'ELL' => 32,
		'Male' => 25,
		'Two or More Races' => 22,
		'Not Economically Disadvantaged' => 24,
		'Not Eligible for Free or Reduced- Price Meals' => 24,
		'Not Eligible For Lunch' => 24,
		'Special Education' => 27,
		'Students with Disabilities' => 27,
		'Not Special Education' => 30,
		'Not Students with Disabilities' => 30,
		'Non-Special Education' => 30,
		'White' => 21,
		'Native Hawaiian or Other Pacific Islander' => 20,
		'Hawaiian or Pacific Islander' => 20,
		'Not English Language Learner' => 33,
		'Not English Language Learners' => 33,
		'Non-ELL' => 33,
		'Non-Binary' => 72
	}

	map_subject_id = {
		'Math' => 5,
		'Composite' => 1,
		'ELA' => 4
	}

	source('school_grad_formatted.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'school',
			notes: 'DXT-3387: CT CSA',
			data_type: 'grad rate',
			data_type_id: 443,
			grade: 'NA',
			subject: 'NA',
			subject_id: 0
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_code: :school_id,
			school: :school_name,
			district_code: :district_id,
			district: :district_name,
			subgroup: :breakdown,
			fouryear_cohort_count: :cohort_count,
			graduation_rate: :value
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:school_id].rjust(7,'0')[0..4]
			row
		end
	end

	source('district_grad_formatted.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'district',
			notes: 'DXT-3387: CT CSA',
			data_type: 'grad rate',
			data_type_id: 443,
			grade: 'NA',
			subject: 'NA',
			subject_id: 0
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			district_code: :district_id,
			district: :district_name,
			subgroup: :breakdown,
			fouryear_cohort_count: :cohort_count,
			graduation_rate: :value
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id].rjust(7,'0')[0..2]
			row
		end
	end

	source('state_grad.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'state',
			notes: 'DXT-3387: CT CSA',
			data_type: 'grad rate',
			data_type_id: 443,
			grade: 'NA',
			subject: 'NA',
			subject_id: 0,
			state_id: 'state'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown,
			fouryear_cohort_count: :cohort_count,
			graduation_rate: :value
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
	end

	source('school_sat_formatted.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'school',
			notes: 'DXT-3387: CT CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_code: :school_id,
			school: :school_name,
			district_code: :district_id,
			district: :district_name,
			subgroup: :breakdown,
			total_numbertested: :cohort_count
		})
		.transform('transpose values',Transposer,:data_type,:value,:ct_school_day_satparticipationrate,:averagescore)
		.transform('delete ELA/Math participation rows',WithBlock) do |row|
			if row[:data_type] == :ct_school_day_satparticipationrate
				if row[:subject] == 'ELA' or row[:subject] == 'Math'
					row[:value] = 'skip'
				else
					row[:data_type_id] = 439
				end
			elsif row[:data_type] == :averagescore
				row[:data_type_id] = 446
			end
			row
		end
		.transform('delete bad values',DeleteRows,:value,'skip','-1','-2','-2.0','*','N/A')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:school_id].rjust(7,'0')[0..4]
			row
		end
	end

	source('district_sat_formatted.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'district',
			notes: 'DXT-3387: CT CSA',
			grade: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			district_code: :district_id,
			district: :district_name,
			subgroup: :breakdown,
			total_numbertested: :cohort_count
		})
		.transform('transpose values',Transposer,:data_type,:value,:ct_school_day_satparticipationrate,:averagescore)
		.transform('delete ELA/Math participation rows',WithBlock) do |row|
			if row[:data_type] == :ct_school_day_satparticipationrate
				if row[:subject] == 'ELA' or row[:subject] == 'Math'
					row[:value] = 'skip'
				else
					row[:data_type_id] = 439
				end
			elsif row[:data_type] == :averagescore
				row[:data_type_id] = 446
			end
			row
		end
		.transform('delete bad values',DeleteRows,:value,'skip','-1','-2','-2.0','*','N/A')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id].rjust(7,'0')[0..2]
			row
		end
	end

	source('state_sat_formatted.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'state',
			notes: 'DXT-3387: CT CSA',
			grade: 'All',
			state_id: 'state'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown,
			total_numbertested: :cohort_count
		})
		.transform('transpose values',Transposer,:data_type,:value,:ct_school_day_satparticipationrate,:averagescore)
		.transform('delete ELA/Math participation rows',WithBlock) do |row|
			if row[:data_type] == :ct_school_day_satparticipationrate
				if row[:subject] == 'ELA' or row[:subject] == 'Math'
					row[:value] = 'skip'
				else
					row[:data_type_id] = 439
				end
			elsif row[:data_type] == :averagescore
				row[:data_type_id] = 446
			end
			row
		end
		.transform('delete bad values',DeleteRows,:value,'skip','-1','-2','-2.0','*','N/A')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('school_postsec.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'school',
			notes: 'DXT-3387: CT CSA',
			grade: 'NA',
			subject: 'NA',
			subject_id: 0
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			school_code: :school_id,
			school: :school_name,
			district_code: :district_id,
			district: :district_name,
			subgroup: :breakdown
		})
		.transform('transpose values',Transposer,:data_type,:value,:persistence,:entrance)
		.transform('delete bad values',DeleteRows,:value,'*','N/A')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:school_id].rjust(7,'0')[0..4]
			row
		end
		.transform('add data type id',WithBlock) do |row|
			if row[:data_type] == :persistence
				row[:data_type_id] = 409
			elsif row[:data_type] == :entrance
				row[:data_type_id] = 474
			end
			row
		end
	end

	source('district_postsec.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'district',
			notes: 'DXT-3387: CT CSA',
			grade: 'NA',
			subject: 'NA',
			subject_id: 0
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			district_code: :district_id,
			district: :district_name,
			subgroup: :breakdown
		})
		.transform('transpose values',Transposer,:data_type,:value,:persistence,:entrance)
		.transform('delete bad values',DeleteRows,:value,'*','N/A')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id].rjust(7,'0')[0..2]
			row
		end
		.transform('add data type id',WithBlock) do |row|
			if row[:data_type] == :persistence
				row[:data_type_id] = 409
			elsif row[:data_type] == :entrance
				row[:data_type_id] = 474
			end
			row
		end
	end

	source('state_postsec.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'state',
			notes: 'DXT-3387: CT CSA',
			grade: 'NA',
			subject: 'NA',
			subject_id: 0,
			state_id: 'state'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown
		})
		.transform('transpose values',Transposer,:data_type,:value,:persistence,:entrance)
		.transform('delete bad values',DeleteRows,:value,'*','N/A')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('add data type id',WithBlock) do |row|
			if row[:data_type] == :persistence
				row[:data_type_id] = 409
			elsif row[:data_type] == :entrance
				row[:data_type_id] = 474
			end
			row
		end
	end

	def config_hash
	{
		source_id: 10,
        state: 'ct'
	}
	end
end

CTMetricsProcessor2019CSA.new(ARGV[0],max:nil).run