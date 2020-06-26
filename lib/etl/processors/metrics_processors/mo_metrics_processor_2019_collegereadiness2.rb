require 'set'
require_relative '../../metrics_processor'

class MOMetricsProcessor2019CollegeReadiness < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3516'
	end

	map_subject_id = {
	  'composite' => 1,
	  :composite => 1,
	  :english => 17,
	  :reading => 2,
	  :math => 5,
	  :science => 19,
	  :any => 89,
	  'na' => 0
	}

	map_breakdown_id = {
	  'All Students' => 1
	}

	map_grade = {
	  'college remediation' => 'NA',
	  'college persistence' => 'NA'
	}

	map_data_type_id = {
	  'college remediation' => 413,
	  'college persistence' => 409
	}

	source('Table_1_2020_all.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'school',
		  breakdown: 'All Students',
		  data_type: 'college remediation'
	    })
	     .transform('rename columns',MultiFieldRenamer, {
		  district_school_code: :school_id,
		  fall_semester: :year,
		  first_time_freshmen: :cohort_count,
		  pct_enrolled_in_remedial_math: :math,
		  pct_enrolled_in_remedial_english: :english,
		  pct_enrolled_in_remedial_reading: :reading,
		  pct_enrolled_in_any_remedial: :any,
	     })
	     .transform('Transpose wide college data types into long',
	       Transposer,
		    :subject,:value,
		    :math,:english,:reading,:any
		  )
	     .transform('delete "." values',DeleteRows,:value,'.')
	     .transform('Adjust remediation values', WithBlock) do |row|
		   row[:value] = row[:value].to_f
		   row
		   end
	end
	source('Table_2_2020_all.txt',[],col_sep:"\t") do |s|
	    s.transform('Fill missing default fields', Fill, {
		  entity_type: 'school',
		  breakdown: 'All Students',
		  data_type: 'college persistence',
		  subject: 'na'
	    })
	     .transform('rename columns',MultiFieldRenamer, {
		  district_school_code: :school_id,
		  fall_semester: :year,
		  first_time_freshmen: :cohort_count,
		  pct_freshmen_sophomore_retention: :value
	     })
	     .transform('delete "." values',DeleteRows,:value,'.')
	     .transform('Adjust persistence values', WithBlock) do |row|
		   row[:value] = row[:value].to_f
		   row
		   end
	     .transform('Adjust year field', WithBlock) do |row|
		   if row[:year].to_s == '2018'
			  row[:year] = '2019'
		   else
			  row[:year] = row[:year].to_s
		   end
		   row
		   end
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3516: MO CSA'
		})
		.transform('Create skip field for year', WithBlock) do |row|
			if row[:year] != '2019'
				row[:skip] = 'Y'
			else
				row[:skip] = 'N'
			end
			row
		end
		.transform('Create state id field', WithBlock) do |row|
			if['college remediation', 'college persistence'].include? row[:data_type]
				row[:split_school_id] = row[:school_id].to_s.split('-')
				row[:state_id] = row[:split_school_id][1] + row[:split_school_id][0]
				if row[:state_id] == '1160048078'
					row[:state_id] = '1580048078'
				elsif row[:state_id] == '1925048078'
					row[:state_id] = '1925048902'
				elsif row[:state_id] == '1945115918'
					row[:state_id] = '1945115906'
				else
					row[:state_id] = row[:state_id]
				end
			end
			row
		end
		.transform('Create date_valid', WithBlock) do |row|
			if row[:year] == '2019'
				row[:date_valid] = '2019-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('Remove quotes and commas from cohort count', WithBlock) do |row|
			row[:cohort_count] = row[:cohort_count].to_s.gsub("\"","")
			row[:cohort_count] = row[:cohort_count].to_s.gsub(",","")
			row
		end
		.transform('delete blank values',DeleteRows,:value,'NULL')
		.transform('delete "*" values',DeleteRows,:value,'*')
		.transform('delete "." values',DeleteRows,:value,'.')
		.transform('skip values that have "Y" in skip field', DeleteRows, :skip, 'Y')
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map grades',HashLookup,:data_type, map_grade,to: :grade)
		.transform('map data type ids',HashLookup,:data_type, map_data_type_id,to: :data_type_id)
	end

	def config_hash
	{
		source_id: 62,
		state: 'mo'
	}
	end
end

MOMetricsProcessor2019CollegeReadiness.new(ARGV[0],max:nil).run