require_relative '../../metrics_processor'

class HIMetricsProcessor2019CSA2 < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3405'
	end

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
		'Pacific Islander'=> 37,
		'White' => 21
	}

	source('transposed_MasterDataFile.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2019-01-01 00:00:00',
			notes: 'DXT-3405: HI CSA',
			subject: 'Not Applicable',
			subject_id: 0,
			grade: 'NA',
			entity_type: 'school'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			name: :school_name,
			subgroup_description: :breakdown
		})
		.transform('delete unwanted school types',DeleteRows,:school_type_for_strive_hi,'Elementary','Middle')
		.transform('delete blank and non-numerical values',DeleteRows,:value,'--',nil)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('setting data_type, and data_type_id',WithBlock) do |row|
			if row[:variable] == "Graduation Rate (%)"
				row[:data_type] = '4-year graduation rate'
				row[:data_type_id] = 443
			elsif row[:variable] == "College Enrollment Rate (%)"
				row[:data_type] = 'college enrollment rate in the last 0-16 months'
				row[:data_type_id] = 414
			end
			row
		end
	end

	def config_hash
	{
		source_id: 15,
        state: 'hi'
	}
	end
end

HIMetricsProcessor2019CSA2.new(ARGV[0],max:nil).run