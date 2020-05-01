require_relative '../../metrics_processor'

class WAMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3462'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'Students with Disabilities' => 27,
		'Students without Disabilities' => 30,
		'Low-Income' => 23,
		'Non-Low Income' => 24,
		'Native Hawaiian/ Other Pacific Islander' => 20,
		'American Indian/ Alaskan Native' => 18,
		'Black/ African American' => 17,
		'Hispanic/ Latino of any race(s)' => 19,
		'White' => 21,
		'Two or More Races' => 22,
		'Asian' => 16,
		'Female' => 26,
		'Male' => 25,
		'Gender X' => 72,
		'English Language Learners' => 32,
		'Non-English Language Learners' => 33
	}

	map_subject_id = {
		'English Language Arts' => 4,
		'Math' => 5
	}

	source('wa_growth_2019.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2019,
	      date_valid: '2019-01-01 00:00:00'
	    })
	end
	source('wa_growth_2018.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      year: 2018,
	      date_valid: '2018-01-01 00:00:00'
	    })
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			studentgroup: :breakdown,
			schoolcode: :school_id,
			schoolname: :school_name,
			districtcode: :district_id,
			districtname: :district_name,
			gradelevel: :grade,
			studentcount: :cohort_count,
			mediansgp: :value
		})
		.transform('skip subgroups',DeleteRows,:breakdown, 'Homeless','Non-Homeless','Migrant','Non Migrant','Military Parent','Non Military Parent','Non Section 504','Section 504')
		.transform('delete suppressed values',DeleteRows,:suppression,'Suppressed: N<10')
		.transform('fix NA student counts to blank',WithBlock) do |row|
			if row[:cohort_count] == 'NA'
				row[:cohort_count] = nil
			end
			row
		end
		.transform('delete NA values',DeleteRows,:value,'NA')
		.transform('fill other columns',Fill,{
			data_type: 'growth',
			data_type_id: 447,
			notes: 'DXT-3462: WA Growth'
		})
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
	    .transform('format grades',WithBlock) do |row|
	    	if row[:grade] == 'All Grades'
	    		row[:grade] = 'All'
	    	else
	    		row[:grade] = row[:grade][0]
	    	end
	    	row
	    end
		.transform('assign state ids and entity level',WithBlock) do |row|
			if row[:organizationlevel] == 'State'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:organizationlevel] == 'District'
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id].rjust(5,'0')
			else
				row[:entity_type] = 'school'
				row[:district_id] = row[:district_id].rjust(5,'0')
				row[:state_id] = row[:school_id]
			end
			row
		end
	end

	def config_hash
	{
		source_id: 52,
        state: 'wa'
	}
	end
end

WAMetricsProcessor2019Growth.new(ARGV[0],max:nil).run