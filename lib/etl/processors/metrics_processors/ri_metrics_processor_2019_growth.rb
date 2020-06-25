require 'set'
require_relative '../../metrics_processor'

class RIMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3538'
	end

	 map_subject_id = {
	 	'ELA' => 4,
	 	'Math' => 5
	}

	map_breakdown_id = {
	'All Students' => 1,
	'American Indian or Alaska Native' => 18,
	'Asian' => 16,
	'Black or African American' => 17,
	'English Learners' => 32,
	'Hispanic' => 19,
	'Economically Disadvantaged' => 23,
	'Native Hawaiian or Other Pacific Islander' => 20,
	'Students with Disabilities' => 27,
	'Two or More Races' => 22,
	'White' => 21
	}

	source('Accountability_201718.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	      year: 2018
	    })
	end
	source('Accountability_201819.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school',
	      year: 2019
	    })
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer, {
	    	distcode: :district_id,
	    	lea_name: :district_name,
	    	schcode: :school_id,
	    	sch_name: :school_name,
	    	group: :breakdown
		})
		.transform('Transpose subject grade columns for values to load', 
	     Transposer, 
	      :field,:value,
	      :growth_index_ela, :growth_index_mat
	      )
		.transform('Assign subject name', WithBlock) do |row|
			if row[:field] == :growth_index_ela
				row[:subject] = 'ELA'
			elsif row[:field] == :growth_index_mat
				row[:subject] = 'Math'
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('create state id field', WithBlock) do |row|
			if row[:entity_type] == 'school'
				row[:state_id] = row[:school_id]
			else
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('assign date valid', WithBlock) do |row|
			if row[:year] == 2018
				row[:date_valid] = '2018-01-01 00:00:00'
			elsif row[:year] == 2019
				row[:date_valid] = '2019-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('Fill missing default fields', Fill, {
			notes: 'DXT-3538: RI Growth',
			grade: 'All',
			data_type: 'growth',
			cohort_count: 'NULL',
			data_type_id: '447'
		})
		.transform('remove "NA" value rows', DeleteRows, :value, 'NA')
		.transform('delete missing values',DeleteRows,:value,nil)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	end

	def config_hash
	{
		source_id: 44,
		state: 'ri'
	}
	end
end

RIMetricsProcessor2019Growth.new(ARGV[0],max:nil).run