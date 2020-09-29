require_relative '../../metrics_processor'

class INMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3407'
	end

	map_subject_id = {
	#college enroll and persist
	'NA' => 0,
	#college remed
	'Any Subject' => 89
	}

map_breakdown_id = {
	'Average' => 1,
	'Asian' => 16,
	'Black' => 17,
	'Non Free or Reduced Lunch' => 24,
	'Free or Reduced Lunch' => 23,
	'Female' => 26,
	'Male' => 25,
	'Hispanic' => 19,
	'White' => 21
	}

	source('ps_enroll_remed_final.txt',[],col_sep:"\t")
	source('ps_persist_final.txt',[],col_sep:"\t")

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3407: IN CSA',
			date_valid: '2018-01-01 00:00:00'
		})
		.transform('Adjust state_ids',WithBlock) do |row|
			if row[:state_id] == '5469' && row[:entity_type] == 'school'
				row[:state_id] = '5462'
			elsif row[:state_id] == '5473' && row[:entity_type] == 'school'
				row[:state_id] = '5474'
			elsif row[:state_id] == '5487' && row[:entity_type] == 'school'
				row[:state_id] = '5492'
			elsif row[:state_id] == '5643' && row[:entity_type] == 'school'
				row[:state_id] = '5644'
			end
			row
		end
		.transform('remove NA values', DeleteRows, :value, 'NA','NaN')
		.transform('Format value to 6 digits', WithBlock) do |row|
			row[:value] = sprintf('%.6f', row[:value]).to_f.to_s
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
	end

	def config_hash
	{
		source_id: 60,
		state: 'in'
	}
	end
end

INMetricsProcessor2019CSA.new(ARGV[0],max:nil).run