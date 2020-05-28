require_relative '../../metrics_processor'

class HIMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3503'
	end

	 map_subject_id = {
	 	'ELA' => 4,
	 	'Math' => 5
	}

	map_breakdown_id = {
	'All Students' => 1,
	'Asian (Excluding Filipino)' => 16,
	'Black' => 17,
	'Disabled (SPED)' => 27,
	'Disadvantaged' => 23,
	'Filipino' => 38,
	'Hispanic' => 19,
	'Limited English (ELL)' => 32,
	'Native Hawaiian' => 41,
	'Pacific Islander' => 37,
	'White' => 21
}

	source('HI_growth_2018.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      date_valid: '2018-01-01 00:00:00'
	    })
	    s.transform('rename columns',MultiFieldRenamer, {
		  schcode: :school_id,
		  common_name: :school_name,
		  subdesc: :breakdown,
		  mathgrowthforsba: :math_growth,
		  ela_growthforsba: :ela_growth,
		  bb_state_id: :state_id
		})
	end
	source('HI_growth_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      date_valid: '2019-01-01 00:00:00'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  subgroup_description: :breakdown,
		  school_name: :school_name,
		  math_median_sgp: :math_growth,
		  reading_median_sgp: :ela_growth,
		  bb_state_id: :state_id
		})
	end

	shared do |s|
		s.transform('Fill missing default fields', Fill, {
			entity_type: 'school',
			data_type: 'growth',
			data_type_id: 447,
			notes: 'DXT-3503: HI Growth',
			cohort_count: 'NULL',
			grade: 'All'
		})
		.transform('Transpose subject grade columns for values to load', 
		 Transposer, 
		  :field_name,:value,
		  :ela_growth, :math_growth
		)
		.transform('assign subject name from transposed field names',WithBlock) do |row|
			if row[:field_name] == :ela_growth
				row[:subject] = 'ELA'
			elsif row[:field_name] == :math_growth
				row[:subject] = 'Math'
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('remove "--" value rows', DeleteRows, :value, '--')
		.transform('delete blank values',DeleteRows,:value,'NA')
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	end

	def config_hash
	{
		source_id: 15,
		state: 'hi'
	}
	end
end

HIMetricsProcessor2019Growth.new(ARGV[0],max:nil).run