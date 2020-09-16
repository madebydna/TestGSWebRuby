require_relative '../../metrics_processor'

class MSMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3609'
	end

	map_breakdown_id = {
		'ALL' => 1,
		'All' => 1,
		'Female' => 26,
		'Male' => 25,
		'Asian' => 16,
		'Black or African American' => 17,
		'Hispanic/Latino' => 19,
		'Hispanic or Latino' => 19,
		'Native American' => 18,
		'American Indian or Alaskan Native' => 18,
		'Native Hawaiian or Pacific Islander' => 20,
		'Pacific Islander' => 37,
		'Two or More Races'=> 22,
		'White' => 21,
		'Students with Disabilities' => 27,
		'Students without Disabilities' => 30,
		'Economically Disadvantaged' => 23,
		'Not Economically Disadvantaged' => 24,
		'English Learners' => 32,
		'Native English Speaker' => 33
	}

	map_subject_id = {
		'Not Applicable' => 0,
		'Composite' => 1,
		'English' => 17,
		'Math' => 5,
		'Any Subject' => 89
	}

	source('GraduationRateState.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2019-01-01 00:00:00',
			year: '2019',
			grade: 'NA',
			data_type: 'grad rate',
			data_type_id: 443,
			subject: 'Not Applicable',
			entity_type: 'state',
			state_id: 'state'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown,
			ncount: :cohort_count,
			graduation_rate: :value
		})
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'Homeless','Not Homeless','Migrant','Non-Migrant')
		.transform('take off % from values',WithBlock) do |row|
			row[:value] = row[:value].to_s.gsub('%', '')	
			row
		end
	end

	source('GraduationRateDistrict.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2019-01-01 00:00:00',
			year: '2019',
			grade: 'NA',
			data_type: 'grad rate',
			data_type_id: 443,
			subject: 'Not Applicable',
			entity_type: 'district',
			breakdown: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			graduation_rate: :value
		})
		.transform('create state ids', WithBlock) do |row|
			row[:state_id] = row[:id].rjust(4,'0')
			row
		end
		.transform('take off % from values',WithBlock) do |row|
			row[:value] = row[:value].to_s.gsub('%', '')	
			row
		end
	end

	source('GraduationRateSchool1.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2019-01-01 00:00:00',
			year: '2019',
			grade: 'NA',
			data_type: 'grad rate',
			data_type_id: 443,
			subject: 'Not Applicable',
			entity_type: 'school',
			breakdown: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			graduation_rate: :value
		})
		.transform('create state ids', WithBlock) do |row|
			row[:state_id] = row[:id].gsub('-','')
			row
		end
		.transform('take off % from values',WithBlock) do |row|
			row[:value] = row[:value].gsub('%', '')	
			row
		end
	end

	source('GraduationRateSchool2.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2019-01-01 00:00:00',
			year: '2019',
			grade: 'NA',
			data_type: 'grad rate',
			data_type_id: 443,
			subject: 'Not Applicable',
			entity_type: 'school',
			breakdown: 'All'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			graduation_rate: :value
		})
		.transform('create state ids', WithBlock) do |row|
			row[:state_id] = row[:id].gsub('-','')
			row
		end
		.transform('take off % from values',WithBlock) do |row|
			row[:value] = row[:value].gsub('%', '')
			row
		end
	end

	source('ACTData.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2019-01-01 00:00:00',
			year: '2019',
			grade: 'All',
			subject: 'Composite'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown
		})
		.transform('assign state id and entity type', WithBlock) do |row|
			if row[:school_name] == 'STATEWIDE'
				row[:state_id] = 'state'
				row[:entity_type] = 'state'
			else
				row[:state_id] = row[:school_unique_id]
				row[:entity_type] = 'school'
			end
			row
		end
		.transform('setting data_type and data_type_id',WithBlock) do |row|
			if row[:variable] == 'Average ACT Score (18-19 Statewide Admin)'
				row[:data_type] = 'ACT average score'
				row[:data_type_id] = 448
			elsif row[:variable] == 'ACT Participation (18-19 Statewide Admin)'
				row[:data_type] = 'ACT participation rate'
				row[:data_type_id] = 396
			else 
				row[:data_type] = 'Error'
				row[:data_type_id] = 'Error'
			end
			row
		end
	end

		source('CollegeData.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2017-01-01 00:00:00',
			year: '2017',
			grade: 'NA'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown
		})
		.transform('assign state id and entity type', WithBlock) do |row|
			if row[:category] == 'Statewide level'
				row[:state_id] = 'state'
				row[:entity_type] = 'state'
			elsif row[:category] == 'District level'
				row[:state_id] = row[:district_number]
				row[:entity_type] = 'district'
			elsif row[:category] == 'School level'
				row[:state_id] = row[:unique_school_id]
				row[:entity_type] = 'school'
			else
				row[:state_id] = 'Error'
				row[:entity_type] = 'Error'
			end
			row
		end
		.transform('Fix state_id for schools that changed districts', WithBlock) do |row|
			if row[:state_id] == '2600010'
				row[:state_id] = '2611010'
			elsif row[:state_id] == '4920006'
				row[:state_id] = '4911006'
			else
				row[:state_id] = row[:state_id]
			end
			row
		end
		.transform('setting data_type, data_type_id, and subject',WithBlock) do |row|
			if row[:variable] == 'Percent Enrolling in MS Public Postsecondary'
				row[:data_type] = 'college enrollment rate'
				row[:data_type_id] = 506
				row[:subject] = 'Not Applicable'
			elsif row[:variable] == 'Percent Taking Remedial Courses'
				row[:data_type] = 'college remediation rate'
				row[:data_type_id] = 413
				row[:subject] = 'Any Subject'
			elsif row[:variable] == 'Percent Retained '
				row[:data_type] = 'college persistence rate'
				row[:data_type_id] = 409
				row[:subject] = 'Not Applicable'
			else 
				row[:data_type] = 'Error'
				row[:data_type_id] = 'Error'
				row[:subject] = 'Error'
			end
			row
		end
	end

	shared do |s|
		s.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3609: MS CSA'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	def config_hash
	{
		source_id: 28,
        state: 'ms'
	}
	end
end

MSMetricsProcessor2019CSA.new(ARGV[0],max:nil).run