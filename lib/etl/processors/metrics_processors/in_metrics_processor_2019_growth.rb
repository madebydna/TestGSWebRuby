require_relative '../../metrics_processor'

class INMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3521'
	end

	map_subject_id = {
	'English/Language Arts' => 4,
	'Mathematics' => 5
	}

map_breakdown_id = {
	'All Students' => 1,
	'Asian' => 16,
	'Black/African-American' => 17,
	'Economically Disadvantaged' => 23,
	'English Learners' => 32,
	'Hawaiian or Pacific Islander' => 20,
	'Hispanic' => 19,
	'Multiracial' => 22,
	'Native American' => 18,
	'Students with Disabilities' => 27,
	'White' => 21
	}

	source('IN_2019_growth_final.txt',[],col_sep:"\t")

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3521: IN Growth'
		})
		.transform('remove None and NA values', DeleteRows, :value, 'NA','None')
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
	end

	def config_hash
	{
		source_id: 18,
		state: 'in'
	}
	end
end

INMetricsProcessor2019Growth.new(ARGV[0],max:nil).run