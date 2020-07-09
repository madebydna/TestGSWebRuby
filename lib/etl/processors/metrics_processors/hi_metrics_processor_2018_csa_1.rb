require_relative '../../metrics_processor'

class HIMetricsProcessor2018CSA1 < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3405'
	end

	map_subject_id = {
		"UH_Math_RemDev_Pct" => 5,
		"UH_Eng_RemDev_Pct" => 17
	}

	map_subject = {
		"UH_Math_RemDev_Pct" => 'Math',
		"UH_Eng_RemDev_Pct" => 'English'
	}

	map_grade = {
	  'ACT participation' => 'All',
	  'persistence rate' => 'NA',
	  'remediation rate' => 'NA'
	}

	map_data_type_id = {
	  'ACT participation' => 396,
	  'persistence rate' => 409,
	  'remediation rate' => 413
	}

	source('transposed_CCRI_Data.txt',[],col_sep:"\t") do |s|
		s.transform('Fill missing default fields', Fill, {
			date_valid: '2018-01-01 00:00:00',
			notes: 'DXT-3405: HI CSA',
			breakdown: "All Students",
			breakdown_id: 1
	    })
	    .transform('rename columns',MultiFieldRenamer,{
			gradyr: :year,
			name: :school_name,
			schcode: :school_id
		})
		.transform('map subject ids',HashLookup,:variable, map_subject_id,to: :subject_id)
		.transform('map subjects',HashLookup,:variable, map_subject,to: :subject)
		.transform('setting entity type and state_id',WithBlock) do |row|
			if row[:school_id] == '999'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'school'
			end
			row
		end
		.transform('setting data_type and cohort_count, and subject and subject_id if not filled yet',WithBlock) do |row|
			if row[:variable] == "ACT_Taken_Pct"
				row[:data_type] = 'ACT participation'
				row[:subject] = 'Composite'
				row[:subject_id] = 1
				row[:cohort_count] = row[:completers]
			elsif row[:variable] == "NSC_Persist_Pct"
				row[:data_type] = 'persistence rate'
				row[:subject_id] = 0
				row[:subject] = "NA"
				row[:cohort_count] = row[:nsc_fall_count]
			else
				row[:data_type] = 'remediation rate'
				row[:cohort_count] = row[:uh_fall]
			end
			row
		end
		.transform('skip unwanted years based on data_type',WithBlock) do |row|
			if row[:data_type] == 'ACT participation' || row[:data_type] == 'remediation rate'
				if row[:year] == '2016' || row[:year] == '2017'
					row[:row_suppressed] = 'skip'
				end
			elsif row[:data_type] == 'persistence rate'
				if row[:year] == '2016' || row[:year] == '2018'
					row[:row_suppressed] = 'skip'
				end
			end
			row	
		end
		.transform('delete blank value rows',DeleteRows,:value,'',nil)	
		.transform('normalize percents and integers',WithBlock) do |row|
			row[:value] = (row[:value].to_f * 100).to_i
			row[:cohort_count] = row[:cohort_count].to_i
			row
		end
		.transform('map grades',HashLookup,:data_type, map_grade,to: :grade)
		.transform('map data type ids',HashLookup,:data_type, map_data_type_id,to: :data_type_id)
		.transform('skip suppressed rows',DeleteRows,:row_suppressed,'skip')
	end

	def config_hash
	{
		source_id: 67,
        state: 'hi'
	}
	end
end

HIMetricsProcessor2018CSA1.new(ARGV[0],max:nil).run