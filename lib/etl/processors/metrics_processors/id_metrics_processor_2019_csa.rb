require_relative '../../metrics_processor'

class IDMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3580'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'American Indian or Alaskan Native' => 18,
		'Asian' => 16,
		'Black / African American' => 17,
		'Economically Disadvantaged' => 23,
		'English Learners' => 32,
		'Female' => 26,
		'Hispanic or Latino' => 19,
		'Male' => 25,
		'Native Hawaiian / Other Pacific Islander' => 20,
		'Not Economically Disadvantaged' => 24,
		'Not English Learners' => 33,
		'Students with Disabilities' => 27,
		'Students without Disabilities' => 30,
		'Two Or More Races' => 22,
		'White' => 21
	}

	map_subject_id = {
		'Reading' => 2,
		'Mathematics' => 5,
		:ls_math_pct => 5,
		'English' => 17,
		:ls_eng_pct => 17,
		'Science' => 19,
		'Composite' => 1,
		'Not Applicable' => 0,
		'Combined Test Score' => 1,
		'Evidence Based Reading and Writing - New' => 2,
		'Math Section Score - New' => 5
	}


	source('grad_school.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'school',
			data_type: 'graduation rate',
			data_type_id: 443,
			notes: 'DXT-3580: ID CSA',
			subject: 'NA',
			subject_id: 0,
			grade: 'NA'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			districtid: :district_id,
			schoolid: :school_id,
			population: :breakdown,
			cohort: :cohort_count,
			rate: :value
		})
		.transform('delete NA value rows',DeleteRows,:value, 'NSIZE','N/A')
		.transform('delete unwanted breakdown values',DeleteRows,:breakdown,'Migratory Students','Non-Migratory Students','Students in Foster Care','Students not in Foster Care','Students of Military Families','Students of Non-Military Families','Students who are Homeless','Students who are not Homeless','Not American Indian or Alaskan Native','Not Asian','Not Black / African American','Not Hispanic or Latino','Not Native Hawaiian / Other Pacific Islander','Not Two Or More Races','Not White')
		.transform('delete old year values',DeleteRows,:cohort_year,'2015','2016','2017','2018','End of Worksheet')
		.transform('delete other carrot values',WithBlock) do |row|
			if row[:value] == '<5%' || row[:value] == '>97%'
				row[:value] = row[:value][0..-2]
			elsif row[:value] =~ /^[><]\d+%$/
				row[:value] = 'skip'
			else
				row[:value] = row[:value][0..-2]
			end
			row
		end
		.transform('delete bad value rows',DeleteRows,:value, 'skip')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id] + row[:school_id]
			row
		end
	end

	source('grad_district.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'district',
			data_type: 'graduation rate',
			data_type_id: 443,
			notes: 'DXT-3580: ID CSA',
			subject: 'NA',
			subject_id: 0,
			grade: 'NA'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			districtid: :district_id,
			population: :breakdown,
			cohort: :cohort_count,
			rate: :value
		})
		.transform('delete NA value rows',DeleteRows,:value, 'NSIZE','N/A')
		.transform('delete unwanted breakdown values',DeleteRows,:breakdown,'Migratory Students','Non-Migratory Students','Students in Foster Care','Students not in Foster Care','Students of Military Families','Students of Non-Military Families','Students who are Homeless','Students who are not Homeless','Not American Indian or Alaskan Native','Not Asian','Not Black / African American','Not Hispanic or Latino','Not Native Hawaiian / Other Pacific Islander','Not Two Or More Races','Not White')
		.transform('delete old year values',DeleteRows,:cohort_year,'2015','2016','2017','2018','End of Worksheet')
		.transform('delete other carrot values',WithBlock) do |row|
			if row[:value] == '<5%' || row[:value] == '>97%'
				row[:value] = row[:value][0..-2]
			elsif row[:value] =~ /^[><]\d+%$/
				row[:value] = 'skip'
			else
				row[:value] = row[:value][0..-2]
			end
			row
		end
		.transform('delete bad value rows',DeleteRows,:value, 'skip')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = row[:district_id]
			row
		end
	end

	source('grad_state.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
			year: 2019,
			date_valid: '2019-01-01 00:00:00',
			entity_type: 'state',
			data_type: 'graduation rate',
			data_type_id: 443,
			notes: 'DXT-3580: ID CSA',
			subject: 'NA',
			subject_id: 0,
			grade: 'NA'
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			population: :breakdown,
			cohort: :cohort_count,
			rate: :value
		})
		.transform('delete NA value rows',DeleteRows,:value, 'NSIZE','N/A')
		.transform('delete unwanted breakdown values',DeleteRows,:breakdown,'Migratory Students','Non-Migratory Students','Students in Foster Care','Students not in Foster Care','Students of Military Families','Students of Non-Military Families','Students who are Homeless','Students who are not Homeless','Not American Indian or Alaskan Native','Not Asian','Not Black / African American','Not Hispanic or Latino','Not Native Hawaiian / Other Pacific Islander','Not Two Or More Races','Not White')
		.transform('delete old year values',DeleteRows,:cohort_year,'2015','2016','2017','2018','End of Worksheet')
		.transform('delete other carrot values',WithBlock) do |row|
			if row[:value] == '<5%' || row[:value] == '>97%'
				row[:value] = row[:value][0..-2]
			elsif row[:value] =~ /^[><]\d+%$/
				row[:value] = 'skip'
			else
				row[:value] = row[:value][0..-2]
			end
			row
		end
		.transform('delete bad value rows',DeleteRows,:value, 'skip')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('create state_ids',WithBlock) do |row|
			row[:state_id] = 'state_id'
			row
		end
	end

	def config_hash
	{
		source_id: 16,
        state: 'id'
	}
	end
end

IDMetricsProcessor2019CSA.new(ARGV[0],max:nil).run