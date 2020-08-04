require_relative '../../metrics_processor'

class ALMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3603'
	end

	map_breakdown_id = {
		'Two or more races' => 22,
		'Asian' => 16,
		'Pacific Islander' => 37,
		'All' => 1,
		'African American' => 17,
		'Economically Disadvantaged' => 23,
		'Female' => 26,
		'Hispanic' => 19,
		'American Indian' => 18,
		'Male'=> 25,
		'White' => 21,
		'English Language Learner' => 32,
		'Not Economically Disadvantaged' => 24,
		'Students with Disabilities' => 27
	}

	map_subject_id = {
		'Composite' => 1,
		'Science' => 19,
		'ELA' => 4,
		'Math' => 5,
		'Not applicable' => 0
	}

	source('transposed_CCADFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'All',
			entity_type: 'school',
	    })
	    .transform('create state ids', WithBlock) do |row|
			row[:state_id] = row[:campus].to_s.gsub('\'', '')
			row
		end
		.transform('delete blank and non-numerical values',DeleteRows,:value,'.','-1')
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/^.2/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/^.3/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/^.4/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/^.A/]
				row[:breakdown] = "All"
			elsif row[:variable][/^.B/]
				row[:breakdown] = "African American"
			elsif row[:variable][/^.E/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/^.F/]
				row[:breakdown] = "Female"
			elsif row[:variable][/^.H/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/^.I/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/^.M/]
				row[:breakdown] = "Male"
			elsif row[:variable][/^.W/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('assign subject',WithBlock) do |row|
			if row[:variable][/^.....A/]
				row[:subject] = "Composite"
			elsif row[:variable][/^.....C/]
				row[:subject] = "Science"
			elsif row[:variable][/^.....E/]
				row[:subject] = "ELA"
			elsif row[:variable][/^.....M/]
				row[:subject] = "Math"
			else
				row[:subject] = "Error"
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('setting data_type and data_type_id',WithBlock) do |row|
			if row[:variable][/^..0CA/]
				row[:data_type] = 'average ACT score'
				row[:data_type_id] = 448
			elsif row[:variable][/^..0CS/]
				row[:data_type] = 'average SAT score'
				row[:data_type_id] = 446
			end
			row
		end
	end

	source('transposed_DCADFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'All',
			entity_type: 'district'
	    })
	    .transform('create state ids', WithBlock) do |row|
			row[:state_id] = row[:district].to_s.gsub('\'', '')
			row
		end
		.transform('delete blank and non-numerical values',DeleteRows,:value,'.','-1')
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/^.2/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/^.3/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/^.4/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/^.A/]
				row[:breakdown] = "All"
			elsif row[:variable][/^.B/]
				row[:breakdown] = "African American"
			elsif row[:variable][/^.E/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/^.F/]
				row[:breakdown] = "Female"
			elsif row[:variable][/^.H/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/^.I/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/^.M/]
				row[:breakdown] = "Male"
			elsif row[:variable][/^.W/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('assign subject',WithBlock) do |row|
			if row[:variable][/^.....A/]
				row[:subject] = "Composite"
			elsif row[:variable][/^.....C/]
				row[:subject] = "Science"
			elsif row[:variable][/^.....E/]
				row[:subject] = "ELA"
			elsif row[:variable][/^.....M/]
				row[:subject] = "Math"
			else
				row[:subject] = "Error"
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('setting data_type and data_type_id',WithBlock) do |row|
			if row[:variable][/^..0CA/]
				row[:data_type] = 'average ACT score'
				row[:data_type_id] = 448
			elsif row[:variable][/^..0CS/]
				row[:data_type] = 'average SAT score'
				row[:data_type_id] = 446
			end
			row
		end
	end

	source('transposed_SCADFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'All',
			entity_type: 'state',
			state_id: 'state',
	    })
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/^.2/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/^.3/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/^.4/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/^.A/]
				row[:breakdown] = "All"
			elsif row[:variable][/^.B/]
				row[:breakdown] = "African American"
			elsif row[:variable][/^.E/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/^.F/]
				row[:breakdown] = "Female"
			elsif row[:variable][/^.H/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/^.I/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/^.M/]
				row[:breakdown] = "Male"
			elsif row[:variable][/^.W/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('assign subject',WithBlock) do |row|
			if row[:variable][/^.....A/]
				row[:subject] = "Composite"
			elsif row[:variable][/^.....C/]
				row[:subject] = "Science"
			elsif row[:variable][/^.....E/]
				row[:subject] = "ELA"
			elsif row[:variable][/^.....M/]
				row[:subject] = "Math"
			else
				row[:subject] = "Error"
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('setting data_type and data_type_id, take decimal places off of SAT scores',WithBlock) do |row|
			if row[:variable][/^..0CA/]
				row[:data_type] = 'average ACT score'
				row[:data_type_id] = 448
			elsif row[:variable][/^..0CS/]
				row[:data_type] = 'average SAT score'
				row[:data_type_id] = 446
				row[:value] = row[:value].to_i
			end
			row
		end
	end

	source('transposed_DistrictDataDownloadFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			subject: 'not applicable',
			subject_id: 0,
			grade: 'NA',
			entity_type: 'district',
			data_type: '4-year high school graduation rate',
			data_type_id: 443
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			distname: :district_name
		})
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district].rjust(6,'0')
			row
		end
		.transform('delete unwanted rows',DeleteRows,:calc_for_state_acct,'No')
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/AAR_GRAD/]
				row[:breakdown] = "African American"
			elsif row[:variable][/ALLR_GRAD/]
				row[:breakdown] = "All"
			elsif row[:variable][/ASR_GRAD/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/_ECNR_GRAD/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/FEMR_GRAD/]
				row[:breakdown] = "Female"
			elsif row[:variable][/_HSR_GRAD/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/LEPHSR_GRAD/]
				row[:breakdown] = "English Language Learner"
			elsif row[:variable][/MALR_GRAD/]
				row[:breakdown] = "Male"
			elsif row[:variable][/MUR_GRAD/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/NAR_GRAD/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/NECNR_GRAD/]
				row[:breakdown] = "Not Economically Disadvantaged"
			elsif row[:variable][/PIR_GRAD/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/SPER_GRAD/]
				row[:breakdown] = "Students with Disabilities"
			elsif row[:variable][/WHR_GRAD/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('matching cohort counts',WithBlock) do |row|
			if row[:breakdown] == 'African American'
				row[:cohort_count] = row[:dist_aad]
			elsif row[:breakdown] == 'All'
				row[:cohort_count] = row[:dist_alld]
			elsif row[:breakdown] == 'Asian'
				row[:cohort_count] = row[:dist_asd]
			elsif row[:breakdown] == 'Economically Disadvantaged'
				row[:cohort_count] = row[:dist_ecnd]
			elsif row[:breakdown] == 'Female'
				row[:cohort_count] = row[:dist_femd]
			elsif row[:breakdown] == 'Hispanic'
				row[:cohort_count] = row[:dist_hsd]
			elsif row[:breakdown] == 'English Language Learner'
				row[:cohort_count] = row[:dist_lepshd]
			elsif row[:breakdown] == 'Male'
				row[:cohort_count] = row[:dist_mald]
			elsif row[:breakdown] == 'Two or more races'
				row[:cohort_count] = row[:dist_mud]
			elsif row[:breakdown] == 'American Indian'
				row[:cohort_count] = row[:dist_nad]
			elsif row[:breakdown] == 'Not Economically Disadvantaged'
				row[:cohort_count] = row[:dist_necnd]
			elsif row[:breakdown] == 'Pacific Islander'
				row[:cohort_count] = row[:dist_pid]
			elsif row[:breakdown] == 'Students with Disabilities'
				row[:cohort_count] = row[:dist_sped]
			elsif row[:breakdown] == 'White'
				row[:cohort_count] = row[:dist_whd]
			else
				row[:cohort_count] = 'Error'
			end
			row
		end
		.transform('fix non-numerical cohort counts',WithBlock) do |row|
			if row[:cohort_count] != nil	
				if row[:cohort_count].include? '<'
					row[:cohort_count] = nil
				elsif row[:cohort_count].include? '-'
					row[:cohort_count] = nil
				end
			end
			row
		end
		.transform('delete non-numerical values',DeleteRows,:value,'.')
	end

	source('transposed_CampusDataDownloadFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			subject: 'not applicable',
			subject_id: 0,
			grade: 'NA',
			entity_type: 'school',
			data_type: '4-year high school graduation rate',
			data_type_id: 443
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			campname: :school_name
		})
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:campus].rjust(9,'0')
			row
		end
		.transform('delete unwanted rows',DeleteRows,:calc_for_state_acct,'No')
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/AAR_GRAD/]
				row[:breakdown] = "African American"
			elsif row[:variable][/ALLR_GRAD/]
				row[:breakdown] = "All"
			elsif row[:variable][/ASR_GRAD/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/_ECNR_GRAD/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/FEMR_GRAD/]
				row[:breakdown] = "Female"
			elsif row[:variable][/_HSR_GRAD/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/LEPHSR_GRAD/]
				row[:breakdown] = "English Language Learner"
			elsif row[:variable][/MALR_GRAD/]
				row[:breakdown] = "Male"
			elsif row[:variable][/MUR_GRAD/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/NAR_GRAD/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/NECNR_GRAD/]
				row[:breakdown] = "Not Economically Disadvantaged"
			elsif row[:variable][/PIR_GRAD/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/SPER_GRAD/]
				row[:breakdown] = "Students with Disabilities"
			elsif row[:variable][/WHR_GRAD/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('matching cohort counts',WithBlock) do |row|
			if row[:breakdown] == 'African American'
				row[:cohort_count] = row[:camp_aad]
			elsif row[:breakdown] == 'All'
				row[:cohort_count] = row[:camp_alld]
			elsif row[:breakdown] == 'Asian'
				row[:cohort_count] = row[:camp_asd]
			elsif row[:breakdown] == 'Economically Disadvantaged'
				row[:cohort_count] = row[:camp_ecnd]
			elsif row[:breakdown] == 'Female'
				row[:cohort_count] = row[:camp_femd]
			elsif row[:breakdown] == 'Hispanic'
				row[:cohort_count] = row[:camp_hsd]
			elsif row[:breakdown] == 'English Language Learner'
				row[:cohort_count] = row[:camp_lepshd]
			elsif row[:breakdown] == 'Male'
				row[:cohort_count] = row[:camp_mald]
			elsif row[:breakdown] == 'Two or more races'
				row[:cohort_count] = row[:camp_mud]
			elsif row[:breakdown] == 'American Indian'
				row[:cohort_count] = row[:camp_nad]
			elsif row[:breakdown] == 'Not Economically Disadvantaged'
				row[:cohort_count] = row[:camp_necnd]
			elsif row[:breakdown] == 'Pacific Islander'
				row[:cohort_count] = row[:camp_pid]
			elsif row[:breakdown] == 'Students with Disabilities'
				row[:cohort_count] = row[:camp_sped]
			elsif row[:breakdown] == 'White'
				row[:cohort_count] = row[:camp_whd]
			else
				row[:cohort_count] = 'Error'
			end
			row
		end
		.transform('fix non-numerical cohort counts',WithBlock) do |row|
			if row[:cohort_count] != nil	
				if row[:cohort_count].include? '<'
					row[:cohort_count] = nil
				elsif row[:cohort_count].include? '-'
					row[:cohort_count] = nil
				end
			end
			row
		end
		.transform('delete non-numerical values',DeleteRows,:value,'.')
	end

	source('transposed_CTXIHEFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'NA',
			entity_type: 'school'
	    })
	    .transform('create state ids', WithBlock) do |row|
			row[:state_id] = row[:campus].to_s.gsub('\'', '')
			row
		end
		.transform('delete blank and non-numerical values',DeleteRows,:value,'.','-1')
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/^.2/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/^.3/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/^.4/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/^.A/]
				row[:breakdown] = "All"
			elsif row[:variable][/^.B/]
				row[:breakdown] = "African American"
			elsif row[:variable][/^.E/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/^.H/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/^.I/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/^.L/]
				row[:breakdown] = "English Language Learner"
			elsif row[:variable][/^.S/]
				row[:breakdown] = "Students with Disabilities"
			elsif row[:variable][/^.W/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('setting data_type, data_type_id, subject, fixing percents for remediation rate',WithBlock) do |row|
			if row[:variable][/HEE18R/]
				row[:data_type] = 'enrollment in TX IHEs'
				row[:data_type_id] = 450
				row[:subject] = 'Not applicable'
			elsif row[:variable][/HEC18R/]
				row[:data_type] = 'percent found needing any remediation'
				row[:data_type_id] = 413
				row[:value] = '%.2f' % (100-row[:value].to_f)
				row[:subject] = 'Composite'
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('transposed_DTXIHEFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'NA',
			entity_type: 'district'
	    })
	    .transform('create state ids', WithBlock) do |row|
			row[:state_id] = row[:district].to_s.gsub('\'', '')
			row
		end
		.transform('delete blank and non-numerical values',DeleteRows,:value,'.','-1')
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/^.2/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/^.3/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/^.4/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/^.A/]
				row[:breakdown] = "All"
			elsif row[:variable][/^.B/]
				row[:breakdown] = "African American"
			elsif row[:variable][/^.E/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/^.H/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/^.I/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/^.L/]
				row[:breakdown] = "English Language Learner"
			elsif row[:variable][/^.S/]
				row[:breakdown] = "Students with Disabilities"
			elsif row[:variable][/^.W/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('setting data_type, data_type_id, subject, fixing percents for remediation rate',WithBlock) do |row|
			if row[:variable][/HEE18R/]
				row[:data_type] = 'enrollment in TX IHEs'
				row[:data_type_id] = 450
				row[:subject] = 'Not applicable'
			elsif row[:variable][/HEC18R/]
				row[:data_type] = 'percent found needing any remediation'
				row[:data_type_id] = 413
				row[:value] = '%.2f' % (100-row[:value].to_f)
				row[:subject] = 'Composite'
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	source('transposed_STXIHEFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			grade: 'NA',
			entity_type: 'state',
			state_id: 'state'
	    })
		.transform('delete blank and non-numerical values',DeleteRows,:value,'.','-1')
		.transform('assign breakdown',WithBlock) do |row|
			if row[:variable][/^.2/]
				row[:breakdown] = "Two or more races"
			elsif row[:variable][/^.3/]
				row[:breakdown] = "Asian"
			elsif row[:variable][/^.4/]
				row[:breakdown] = "Pacific Islander"
			elsif row[:variable][/^.A/]
				row[:breakdown] = "All"
			elsif row[:variable][/^.B/]
				row[:breakdown] = "African American"
			elsif row[:variable][/^.E/]
				row[:breakdown] = "Economically Disadvantaged"
			elsif row[:variable][/^.H/]
				row[:breakdown] = "Hispanic"
			elsif row[:variable][/^.I/]
				row[:breakdown] = "American Indian"
			elsif row[:variable][/^.L/]
				row[:breakdown] = "English Language Learner"
			elsif row[:variable][/^.S/]
				row[:breakdown] = "Students with Disabilities"
			elsif row[:variable][/^.W/]
				row[:breakdown] = "White"
			else
				row[:breakdown] = "Error"
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('setting data_type, data_type_id, subject, fixing percents for remediation rate',WithBlock) do |row|
			if row[:variable][/HEE18R/]
				row[:data_type] = 'enrollment in TX IHEs'
				row[:data_type_id] = 450
				row[:subject] = 'Not applicable'
			elsif row[:variable][/HEC18R/]
				row[:data_type] = 'percent found needing any remediation'
				row[:data_type_id] = 413
				row[:value] = '%.2f' % (100-row[:value].to_f)
				row[:subject] = 'Composite'
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	shared do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2018-01-01 00:00:00',
			year: '2018',
			notes: 'DXT-3467: TX CSA'
		})
		.transform('fix cohort counts with commas', WithBlock) do |row|
			if row[:cohort_count] != nil
				row[:cohort_count] = row[:cohort_count].to_s.gsub(',', '')
			end
			row
		end
	end

	def config_hash
	{
		source_id: 69,
        state: 'al'
	}
	end
end

ALMetricsProcessor2019CSA.new(ARGV[0],max:nil).run