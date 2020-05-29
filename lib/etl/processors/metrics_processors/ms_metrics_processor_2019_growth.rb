require_relative '../../metrics_processor'

class MSMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3526'
	end

	 map_subject_id = {
	 	'Reading' => 2,
	 	'Math' => 5
	}

	source('school_2018_1.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	      year: '2018'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
	     id: :school_id
		})
	end
	source('school_2018_2.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	      year: '2018'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
	     id: :school_id
		})
	end
	source('district_2018.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'district',
	      school_id: '',
	      school_name: 'district',
	      year: '2018'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
	     id: :district_id
		})
	end
	source('school_2019_1.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	      year: '2019'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
	     id: :school_id
		})
	end
	source('school_2019_2.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	      year: '2019'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
	     id: :school_id
		})
	end
	source('school_2019_3.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	      year: '2019'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
	     id: :school_id
		})
	end
	source('district_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'district',
	      school_id: '',
	      school_name: 'district',
	      year: '2019'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
	     id: :district_id
		})
	end

	shared do |s|
		s.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3526: MS Growth',
			grade: 'All',
			data_type: 'growth',
			data_type_id: 447,
			breakdown: 'All Students',
			breakdown_id: 1,
			cohort_count: 'NULL'
		})
		.transform('Transpose subject grade columns for values to load', 
	     Transposer, 
	      :field,:value,
	      :reading_growth,:math_growth
	      )
		.transform('create subject name', WithBlock) do |row|
			if row[:field] == :reading_growth
				row[:subject] = 'Reading'
			elsif row[:field] == :math_growth
				row[:subject] = 'Math'
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('remove hyphen from school ids and zero pad district ids', WithBlock) do |row|
			if row[:entity_type] == 'school'
				row[:school_id] = row[:school_id].to_s.gsub('-', '')
				if row[:school_id].to_s.length == 6
					row[:school_id] = '0' + (row[:school_id].to_s)
				end
			elsif row[:entity_type] == 'district'
				if row[:district_id].to_s.length == 3
					row[:district_id] = '0' + row[:district_id].to_s
				else
					row[:district_id]
				end
			end
			row
		end
		.transform('create state id field', WithBlock) do |row|
			if row[:entity_type] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_type] == 'school'
				row[:state_id] = row[:school_id]
			else
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('replace state ids for schools who changed districts', WithBlock) do |row|
			if row[:entity_type] == 'school'
				if row[:state_id] == '2600010'
					row[:state_id] = '2611010'
				elsif row[:state_id] == '2600008'
					row[:state_id] = '2611008'
				elsif row[:state_id] == '2600006'
					row[:state_id] = '2611006'
				elsif row[:state_id] == '2600024'
					row[:state_id] = '2611024'
				elsif row[:state_id] == '2600004'
					row[:state_id] = '2611004'
				elsif row[:state_id] == '2600018'
					row[:state_id] = '2611018'
				elsif row[:state_id] == '4920004'
					row[:state_id] = '4911004'
				elsif row[:state_id] == '4920006'
					row[:state_id] = '4911006'
				else
					row[:state_id] = row[:state_id]
				end
			end
			row
		end
		.transform('assign date valid', WithBlock) do |row|
			if row[:year] == '2018'
				row[:date_valid] = '2018-01-01 00:00:00'
			elsif row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('remove NA value rows', DeleteRows, :value, 'NA')
		.transform('remove NA value rows', DeleteRows, :value, 'N/A')
		.transform('remove _ value rows', DeleteRows, :value, '_')
		.transform('delete "ǂ" values',DeleteRows,:value,'ǂ')
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end

	def config_hash
	{
		source_id: 28,
		state: 'ms'
	}
	end
end

MSMetricsProcessor2019Growth.new(ARGV[0],max:nil).run