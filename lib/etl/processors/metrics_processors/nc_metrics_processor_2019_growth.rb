require_relative '../../metrics_processor'

class NCMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3359'
	end

	map_breakdown_id = {
		'ALL' => 1,
		'SWD' => 27,
		'EDS' => 23,
		'AM7' => 18,
		'BL7' => 17,
		'HI7' => 19,
		'WH7' => 21,
		'MU7' => 22,
		'AS7' => 16,
		'ELS' => 32,
	}

	 map_subject_id = {
		'Composite' => 1,
	 	'Reading' => 2,
	 	'Math' => 5,
	}

	source('rcd_acc_spg2.txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown
		})
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			data_type_id: 447,
			notes: 'DXT-3359: NC Growth',
			grade: 'All',
			cohort_count: 'NULL'
		})
		.transform('assign date_valid based on year',WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			end
			row
		end
		.transform('assign state ids and entity level',WithBlock) do |row|
			if row[:agency_code] == 'NC-SEA'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:agency_code] != 'NC-SEA'
				row[:entity_type] = 'school'
				if row[:agency_code] == '4.90E+01'
				 	row[:state_id] = '49E000'
				elsif row[:agency_code] == '9.20E+01'
				 	row[:state_id] = '92E000'
				elsif row[:agency_code].length == 5
					row[:state_id] = '0' + row[:agency_code]
				else
					row[:state_id] = row[:agency_code]
				end
			end
			row
		end
		.transform('transpose subject columns',Transposer,:subject,:value,:eg_score,:ma_eg_score,:rd_eg_score)
		.transform('rename subjects',WithBlock) do |row|
			if row[:subject] == :eg_score
				row[:subject] = 'Composite'
			elsif row[:subject] == :rd_eg_score
				row[:subject] = 'Reading'
			elsif row[:subject] == :ma_eg_score
				row[:subject] = 'Math'
			end
			row
		end
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	end


	def config_hash
	{
		source_id: 37,
        state: 'nc'
	}
	end
end

NCMetricsProcessor2019Growth.new(ARGV[0],max:nil).run