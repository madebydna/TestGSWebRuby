require 'set'
require_relative '../../metrics_processor'

class VTMetricsProcessor2019CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3594'
	end


	map_breakdown_id = {
	  'All Students' => 1
	}

	map_subject_id = {
		'NA' => 0,
		'sat_2018_erw_mean' => 2,
		'sat_2018_math_mean' => 5,
		'sat_2018_total_mean' => 1

	}

	map_data_type_id = {
		'SAT Avg Score' => 446,
		'enrollment_rate' => 414,
		'persistence_rate' => 409
	}



	source('vt_2018_2019.txt',[],col_sep:"\t") 


	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3594: VT CSA'
		})
		.transform('Create date_valid', WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map datatype ids',HashLookup,:data_type, map_data_type_id,to: :data_type_id)
		.transform('Trim values', WithBlock) do |row|
			row[:value] = sprintf('%.6f', row[:value]).to_f.to_s
			row
		end
	end

	def config_hash
	{
		source_id: 50,
		state: 'vt'
	}
	end
end

VTMetricsProcessor2019CollegeReadiness.new(ARGV[0],max:nil).run