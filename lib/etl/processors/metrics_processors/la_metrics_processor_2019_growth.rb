require_relative '../../metrics_processor'

class LAMetricsProcessor2019Growth < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3504'
	end

	 map_subject_id = {
	 	'ELA' => 4,
	 	'Math' => 5
	}

	source('2019-state-lea-leap-2025-progress-summary.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      school_id: '',
	      school_name: 'all schools'
	    })
	    s.transform('rename columns',MultiFieldRenamer, {
		  school_system_code: :district_id,
		  school_system_name: :district_name
		})
	end
	source('2019-school-leap-20255-progress-summary_clean.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
	      entity_type: 'school'
	    })
	    .transform('rename columns',MultiFieldRenamer, {
		  district_state_id: :district_id,
		  school_system_name: :district_name,
		  school_state_id: :school_id,
		  site_name: :school_name
		})
	end

	shared do |s|
		s.transform('Fill missing default fields', Fill, {
			year: 2019,
			data_type: 'percent growth',
			data_type_id: 460,
			date_valid: '2019-01-01 00:00:00',
			notes: 'DXT-3504: LA Percentage of students meeting growth target',
			breakdown: 'All Students',
			breakdown_id: 1,
			cohort_count: 'NULL',
			grade: 'All'
		})
		.transform('Transpose subject grade columns for values to load', 
		 Transposer, 
		  :field_name,:value,
		  :ela_grades_38_english_i__ii_2019__top_growth,
		  :math_grades_38_algebra_i__geometry_2019__top_growth
		)
		.transform('Adding short subject names',WithBlock) do |row|
			if row[:field_name] == :ela_grades_38_english_i__ii_2019__top_growth
				row[:subject] = 'ELA'
			elsif row[:field_name] == :math_grades_38_algebra_i__geometry_2019__top_growth
				row[:subject] = 'Math'
			else
				row[:subject] = 'Error'
			end
			row
		end
		.transform('Adjusting entity_type for district file',WithBlock) do |row|
			if row[:entity_type] == 'school'
				row[:entity_type] = row[:entity_type]
			elsif row[:entity_type] != 'school'
				if row[:district_id] == 'state'
					row[:entity_type] = 'state'
				elsif row[:district_id] != 'State'
					row[:entity_type] = 'district'
				else
					row[:entity_type] = 'school'
				end
			else
				row[:entity_type] = 'school'
			end
			row
		end
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('create state_id field', WithBlock) do |row|
			if row[:entity_type] == 'district'
				if row[:district_id] == 'R36'
					row[:state_id] = '036'
				else
					row[:state_id] = row[:district_id]
				end
			elsif row[:entity_type] == 'school'
				if row[:db_school_state_id] == 'NA'
					row[:state_id] = row[:school_id]
				elsif row[:db_school_state_id] != 'NA'
					row[:state_id] = row[:db_school_state_id]
				else
					row[:state_id] = 'Error'
				end
			elsif row[:entity_type] == 'state'
				row[:state_id] = 'state'
			else
				row[:entity_type] = 'Error'
			end
			row
		end
		.transform('remove "NR" value rows', DeleteRows, :value, 'NR')
		.transform('remove East Baton Rouge Parish-EBR and RSD rows', DeleteRows, :district_id, '017+RBR')
		.transform('remove Diocese of Baton Rouge Special Education Program rows', DeleteRows, :school_id, '502048')
		.transform('Replace inequality values',WithBlock) do |row|
			if row[:value] == '<=1'
				row[:value] = '1'
			elsif row[:value] != "<=1"
				row[:value] = row[:value]
			else
				row[:value] = 'Error'
			end
			row
		end
	end


	def config_hash
	{
		source_id: 22,
        state: 'la'
	}
	end
end

LAMetricsProcessor2019Growth.new(ARGV[0],max:nil).run