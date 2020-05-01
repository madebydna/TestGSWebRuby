require_relative '../../metrics_processor'

class NYMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3471'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'Students with Disabilities' => 27,
		'American Indian or Alaska Native' => 18,
		'Asian or Native Hawaiian/Other Pacific Islander' => 15,
		'Black or African American' => 17,
		'Hispanic or Latino' => 19,
		'White' => 21,
		'Multiracial' => 22,
		'English Language Learners' => 32,
		'Economically Disadvantaged' => 23
	}

	source('Growth_2018_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      subject: 'Composite',
	      subject_id: 1,
	      data_type: 'growth',
	      data_type_id: 447,
	      notes: 'DXT-3471: NY Growth',
		  grade: 'All'
	    })
	    .transform('Fill date_valid based on year', WithBlock) do |row|
	    	if row[:year] == '2018'
	    		row[:date_valid] = '2018-01-01 00:00:00'
	    	elsif row[:year] == '2019'
	      		row[:date_valid] = '2019-01-01 00:00:00'
	      	end
	      	row
	    end
		.transform('rename columns',MultiFieldRenamer,{
			entity_cd: :state_id,
			subgroup_name: :breakdown,
			sgp_students: :cohort_count,
			index: :value
		})
		.transform('delete suppressed value rows',DeleteRows,:value, 's')
		.transform('skip cohort count value 0 through 10',WithBlock) do |row|
			if row[:cohort_count].to_i.between?(0,10)
				row[:cohort_count] = nil
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('Fix state state_id and differentiate districts and schools',WithBlock) do |row|
			if row[:state_id] == '111111111111'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:state_id].to_s[-4,4] == '0000'
				row[:entity_type] = 'district'
				row[:district_name] = row[:entity_name]
			else 
				row[:entity_type] = 'school'
				row[:school_name] = row[:entity_name]
			end
			row
		end
	end

	def config_hash
	{
		source_id: 36,
        state: 'ny'
	}
	end
end

NYMetricsProcessor2019Growth.new(ARGV[0],max:nil).run