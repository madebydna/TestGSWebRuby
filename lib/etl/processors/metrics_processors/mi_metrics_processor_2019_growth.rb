require_relative '../../metrics_processor'

class MIMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3355'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'Students with Disabilities' => 27,
		'Students without Disabilities' => 30,
		'Economically Disadvantaged' => 23,
		'Not Economically Disadvantaged' => 24,
		'Native Hawaiian or Other Pacific Islander' => 20,
		'American Indian or Alaska Native' => 18,
		'Black, not of Hispanic origin' => 17,
		'Hispanic' => 19,
		'White, not of Hispanic origin' => 21,
		'Two or More Races' => 22,
		'Asian' => 16,
		'Female' => 26,
		'Male' => 25,
		'English Learners' => 32,
		'Not English Learners' => 33
	}

	map_subject_id = {
		'English Language Arts' => 4,
		'Mathematics' => 5,
		'Social Studies' => 18,
		'Science' => 19
	}

	source('MI_1819_growth.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2019,
	      date_valid: '2019-01-01 00:00:00'
	    })
	end
	source('MI_1718_growth.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00'
	    })
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			testinggroup: :breakdown,
			buildingcode: :school_id,
			buildingname: :school_name,
			districtcode: :district_id,
			districtname: :district_name,
			meansgp: :value
		})
		.transform('tag non-loadable data and fix breakdown',WithBlock) do |row|
	    	if row[:isdname] != 'Statewide' and row[:district_name] == 'All Districts' and row[:school_name] == 'All Buildings'
	    		row[:value] = '*'
	    	end
	    	row[:breakdown] = row[:breakdown].gsub('"','')
	    	row
	    end	
		.transform('skip subgroups',DeleteRows,:breakdown, 'Migrant','Not Migrant')
		.transform('delete non-loadable data and value < 10',DeleteRows,:value,'*','< 10',nil)
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			data_type_id: 447,
			notes: 'DXT-3355: MI Growth'
		})
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	    .transform('update grade all',WithBlock) do |row|
	    	if row[:grade] == 'All Grades'
	    		row[:grade] = 'All'
	    	end
	    	row
	    end		
		.transform('assign state ids and entity level',WithBlock,) do |row|
			if row[:isdname] == 'Statewide'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:school_name] == 'All Buildings'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id].rjust(5,'0')
			else
				row[:entity_type] = 'school'
				row[:district_id] = row[:district_id].rjust(5,'0')
				row[:state_id] = row[:school_id].rjust(5,'0')
			end
			row
		end
	end

	def config_hash
	{
		source_id: 26,
        state: 'mi'
	}
	end
end

MIMetricsProcessor2019Growth.new(ARGV[0],max:nil).run