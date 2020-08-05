require_relative '../../metrics_processor'

class ALMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3603'
	end

	map_subject_id = {
		'Composite' => 1,
		'English' => 17,
		'Math' => 5,
		'Any Subject' => 89
	}

	source('CollegeRemediation.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2019-01-01 00:00:00',
			year: '2019',
			notes: 'DXT-3603: AL CSA',
			grade: 'NA',
			data_type: 'remediation rate',
			data_type_id: 413,
			breakdown: 'All Students',
			breakdown_id: 1
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			cohort_count_nocommas: :cohort_count
		})
		.transform('setting entity type and state_id',WithBlock) do |row|
			if row[:school_name] == 'TOTAL ALL ALABAMA PUBLIC SCHOOLS'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'school'
				row[:state_id] = row[:state_id].rjust(7,'0')
			end
			row
		end
		.transform('assign subject',WithBlock) do |row|
			if row[:variable][/composite_remed_rate/]
				row[:subject] = 'Composite'
			elsif row[:variable][/any_remed_rate/]
				row[:subject] = 'Any Subject'
			elsif row[:variable][/english_remed_rate/]
				row[:subject] = 'English'
			elsif row[:variable][/math_remed_rate/]
				row[:subject] = 'Math'
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	def config_hash
	{
		source_id: 69,
        state: 'al'
	}
	end
end

ALMetricsProcessor2019CSA.new(ARGV[0],max:nil).run