require_relative '../../metrics_processor'

class ORMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3470'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'Economically Disadvantaged' => 23,
		'Students with Disabilities' => 27,
		'English Learners' => 32,
		'American Indian/Alaska Native' => 18,
		'Black/African American' => 17,
		'Hispanic/Latino' => 19,
		'Native Hawaiian/Pacific Islander' => 20,
		'Asian' => 16,
		'Multiracial' => 22,
		'White' => 21
	}

	source('ELA_Growth_2018_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  subject: 'English Language Arts',
		  subject_id: 4
	    })
	end

	source('Math_Growth_2018_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  subject: 'Math',
		  subject_id: 5
	    })
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			student_group: :breakdown,
			school: :school_name,
			district: :district_name
		})
		.transform('delete unwanted breakdown rows',DeleteRows,:breakdown,'Underserved Race/Ethnicity')
		.transform('transpose value columns',Transposer,:year,:value,:median_201718,:median_201819)
		.transform('prepare to delete suppressed rows',WithBlock) do |row|
			if row[:year] == :median_201718
				if row[:denominator_201718] == '*'
					row[:row_suppressed] = 'skip'
				elsif row[:median_201718] == '*'
					row[:row_suppressed] = 'skip'
				end
			elsif row[:year] == :median_201819
				if row[:denominator_201819] == '*'
					row[:row_suppressed] = 'skip'
				elsif row[:median_201819] == '*'
					row[:row_suppressed] = 'skip'
				end
			end
			row
		end
		.transform('delete suppressed rows',DeleteRows,:row_suppressed,'skip')
		.transform('fill other columns',Fill,{
			data_type: 'growth',
	      	data_type_id: 447,
	      	notes: 'DXT-3470: OR Growth',
		  	grade: 'All',
		  	entity_type: 'school'
		})
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('create state ids',WithBlock) do |row|
			row[:state_id] = row[:school_id].rjust(20, '0')
		row
		end
		.transform('fix years, assign date_valid, load cohort count', WithBlock) do |row|
	    	if row[:year] == :median_201718
	    		row[:year] = 2018
	    		row[:date_valid] = '2018-01-01 00:00:00'
	    		row[:cohort_count] = row[:denominator_201718]
	    	elsif row[:year] == :median_201819
	      		row[:year] = 2019
	      		row[:date_valid] = '2019-01-01 00:00:00'
	      		row[:cohort_count] = row[:denominator_201819]
	      	end
	      	row
	    end
	end

	def config_hash
	{
		source_id: 42,
        state: 'or'
	}
	end
end

ORMetricsProcessor2019Growth.new(ARGV[0],max:nil).run