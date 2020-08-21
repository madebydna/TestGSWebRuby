require_relative '../../metrics_processor'

class NCMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3598'
	end

	map_breakdown_id = {
		'All Students' => 1,
		'ALL' => 1,
		'AMIN' => 18,
		'ASIA' => 16,
		'BLCK' => 17,
		'HISP' => 19,
		'MULT' => 22,
		'WHTE' => 21,
		'EDS' => 23,
		'ELS' => 32,
		'SWD' => 27,
		'FEM' => 26,
		'MALE' => 25,
		'NEDS' => 24,
		'NSWD' => 30
	}

	map_subject_id = {
		'NA' => 0,
		:total => 1,
		:erw => 2,
		:math => 5,
		'Math' => 5,
		'Reading' => 2,
		'English' => 17,
		'Science' => 19,
		'Composite' => 1,
		'All Four' => 1
	}

map_grade = {
		443 => 'NA',
		439 => 'All',
		446 => 'All',
		448 => 'All',
		454 => 'All',
		505 => 'NA',
		489 => 'NA',
		488 => 'NA'
}


	source('2019-sat-performance-district-school.txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			school_system_code: :district_id,
			school_system__school: :school_id
		})
		.transform('fill other columns',Fill,{
			breakdown: 'All Students',
			year: 2019
		})
		.transform('assign state ids and entity level',WithBlock) do |row|
			if row[:school_name] == ' North Carolina (Public School Students) '
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif [' United States (Public School Students) ',' NC School of Science & Math ',' NC School of The Arts '].include? row[:school_name]
				row[:entity_type] = 'Skip'
			elsif row[:school_name].nil?
				row[:entity_type] = 'district'
				row[:state_id] = row[:district_id].to_s.strip
			elsif row[:school_id].to_s.length == 3
				row[:entity_type] = 'school'
				row[:state_id] = row[:district_id].to_s.strip + row[:school_id]
			else
				row[:entity_type] = 'Skip'
			end
			row
		end
		.transform('transpose subject columns',Transposer,:subject_data_type,:value,:pct_tested,:total,:erw,:math)
		.transform('Assign data type id and assign subject for SAT part', WithBlock) do |row|
			if row[:subject_data_type] == :pct_tested
				row[:subject] = 'Composite'
				row[:data_type] = 'SAT Participation'
				row[:data_type_id] = 439
			else
				row[:subject] = row[:subject_data_type]
				row[:data_type] = 'SAT average score'
				row[:data_type_id] = 446
			end
			row
		end
		.transform('Assign cohort_count values and columns', WithBlock) do |row|
			if row[:data_type_id] == 439
				row[:cohort_count] = 'NULL'
			elsif row[:data_type_id] == 446
				row[:cohort_count] = row[:num_tested]
			else
				row[:cohort_count] = 'Error'
			end
			row
		end
	end
	source('actgrads1819_final.txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			school_system_code: :district_id,
			school_code: :school_id,
			school_system__school: :school_name,
			tested: :cohort_count
		})
		.transform('fill other columns',Fill,{
			breakdown: 'All Students',
			year: 2019,
			subject: 'NA'
		})
		.transform('assign state ids and entity level',WithBlock) do |row|
			if row[:school_name] == 'State of North Carolina (Public Students)'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
				row[:district_id] = 'state'
				row[:school_id] = 'state'
			elsif ['United States (All Students)','North Carolina (All Students)','NC School Of Science & Math','NC School Of The Arts'].include? row[:school_name]
					row[:entity_type] = 'Skip'
			elsif row[:school_name].nil?
					row[:entity_type] = 'district'
					row[:state_id] = row[:district_id]
			elsif row[:school_id].to_s.length == 6
				row[:entity_type] = 'school'
				row[:state_id] = row[:school_id]
			end
			row
		end
		.transform('delete bad entities values',DeleteRows,:entity_type,"Skip")
		.transform('transpose data type and subject columns',Transposer,:subject_data_type,:value,:average_composite_score,:average_english_score,:_met_english_benchmark,:average_math_score,:_met_math_benchmark,:average_reading_score,:_met_reading_benchmark,:average_science_score,:_met_science_benchmark,:_met_all_four_benchmarks)
		.transform('Set data type id and subject value', WithBlock) do |row|
			if [:average_composite_score,:average_english_score,:average_math_score,:average_reading_score,:average_science_score].include? row[:subject_data_type]
				row[:data_type_id] = 448
				row[:data_type] = 'ACT average score'
				row[:subject] = row[:subject_data_type].to_s.split('_')[1].capitalize
			elsif [:_met_english_benchmark,:_met_math_benchmark,:_met_reading_benchmark,:_met_science_benchmark].include? row[:subject_data_type]
				row[:data_type_id] = 454
				row[:data_type] = 'ACT percent college ready'
				row[:subject] = row[:subject_data_type].to_s.split('_')[2].capitalize
			elsif row[:subject_data_type] == :_met_all_four_benchmarks
				row[:data_type_id] = 454
				row[:data_type] = 'ACT percent college ready'
				row[:subject] = 'All Four'
			else
				row[:data_type_id] = 'Error'
				row[:subject] = 'Error'
			end
			row
		end
	end
	source('4-5yrcgrdisag2019.txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			school_code: :school_id,
			reporting_year: :year,
			subgroup: :breakdown,
			denominator: :cohort_count,
			pct: :value
		})
		.transform('fill other columns',Fill,{
			subject: 'NA',
			data_type: 'graduation rate',
			data_type_id: 443
		})
		.transform('assign state ids and entity level',WithBlock) do |row|
			if row[:school_id] == 'NC-SEA'
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
			elsif row[:school_id][3..5] =='LEA'
				row[:entity_type] = 'district'
				row[:state_id] = row[:school_id][0..2]
			elsif row[:school_id][3..5] !='LEA'
				row[:entity_type] = 'school'
				row[:state_id] = row[:school_id]
			else
				row[:entity_type] = 'Skip'
			end
			row
		end
		.transform('Mark extra years for skipping', WithBlock) do |row|
			if row[:year].to_i < 2019
				row[:year_skip] = 'Skip'
			else
				row[:year_skip] = 'NULL'
			end
			row
		end
		.transform('delete extra years',DeleteRows,:year_skip,"Skip")
		.transform('delete Gifted breakdown',DeleteRows,:breakdown,"AIG")
		.transform('delete Homeless breakdown',DeleteRows,:breakdown,"HMS")
		.transform('delete Foster Care breakdown',DeleteRows,:breakdown,"FCS")
		.transform('delete Military breakdown',DeleteRows,:breakdown,"MIL")
		.transform('delete Migrant breakdown',DeleteRows,:breakdown,"MIG")
	end
	source('School Level College Enrollment Counts and Percentages (2015-16 thru 2018-19).txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			reporting_year: :year,
			lea: :district_id,
			lea_name: :district_name,
			sch: :school_id,
			total_graduated: :cohort_count,
			percent_enrolled: :value
		})
		.transform('fill other columns',Fill,{
			breakdown: 'All Students',
			subject: 'NA',
			data_type: 'college enrollment',
			data_type_id: 505,
			entity_type: 'school'
		})
		.transform('Assign entity_type and create state_id', WithBlock) do |row|
			row[:state_id] = row[:district_id].to_s + row[:school_id].to_s
			row
		end
		.transform('Convert decimal values to percent and trim', WithBlock) do |row|
			row[:value] = row[:value].to_f * 100.0
			row[:value] = row[:value].round(6)
			row
		end
	end
	source('2017 NC Public HS Graduates Fall 2017 to Fall 2018 Persistence Rate.txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			high_school_last_attd_nm: :school_name,
			high_school_last_attd_cd: :state_id,
			lea_number: :district_id,
			high_school_last_attd_lea_nm: :district_name,
			fall_2017_sid_count: :cohort_count,
			persit_rate: :value
		})
		.transform('fill other columns',Fill,{
			breakdown: 'All Students',
			subject: 'NA',
			data_type: '2 year college persistence',
			data_type_id: 489,
			entity_type: 'school',
			year: 2018
		})
		.transform('Mark extraneous college types for skipping', WithBlock) do |row|
			if row[:college_nm] == 'NCCCS Total'
				row[:skip_college] = 'NULL'
			else
				row[:skip_college] = 'Skip'
			end
			row
		end
		.transform('delete duplicative Junius Rose High values',DeleteRows,:state_id,"740389")
		.transform('Adjust state_ids', WithBlock) do |row|
			if row[:state_id] == '390222'
				row[:state_id] = '390322'
			elsif row[:state_id] == '830346'
				row[:state_id] = '830343'
			elsif row[:state_id] == '422324'
				row[:state_id] = '422315'
			else
				row[:state_id] = row[:state_id]
			end
			row
		end
		.transform('delete skip college values',DeleteRows,:skip_college,"Skip")
	end
	source('gradret_012_great_schools_retention_13JAN20_school.txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			year: :cohort_year,
			dpi_school_number: :state_id,
			lea_name: :district_name,
			lea_number: :district_id,
			freshmen_count: :cohort_count,
			persistence_rate: :value
		})
		.transform('fill other columns',Fill,{
			breakdown: 'All Students',
			subject: 'NA',
			data_type: '4 year college persistence',
			data_type_id: 488,
			entity_type: 'school',
			year: 2018
		})
		.transform('Mark extraneous college types for skipping', WithBlock) do |row|
			if row[:unc_university] == 'UNC Total'
				row[:skip_college] = 'NULL'
			else
				row[:skip_college] = 'Skip'
			end
			row
		end
		.transform('Adjust state ids', WithBlock) do |row|
			if row[:state_id] == '520344'
				row[:state_id] = '520320'
			elsif row[:state_id] == '4.90E+'
				row[:state_id] = '49E000'
			else
				row[:state_id] = row[:state_id]
			end
			row
		end
		.transform('delete skip college values',DeleteRows,:skip_college,"Skip")
		.transform('delete South Granville Hlt/Sci values',DeleteRows,:school_name,"South Granville Hlth/Life Sci")
	end
	source('gradret_012_great_schools_retention_13JAN20_district.txt',[],col_sep:"\t") do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			year: :cohort_year,
			lea_name: :district_name,
			lea_number: :state_id,
			freshmen_count: :cohort_count,
			persistence_rate: :value
		})
		.transform('fill other columns',Fill,{
			breakdown: 'All Students',
			subject: 'NA',
			data_type: '4 year college persistence',
			data_type_id: 488,
			entity_type: 'district',
			year: 2018
		})
		.transform('Mark extraneous college types for skipping', WithBlock) do |row|
			if row[:unc_university] == 'UNC Total'
				row[:skip_college] = 'NULL'
			else
				row[:skip_college] = 'Skip'
			end
			row
		end
		.transform('delete skip college values',DeleteRows,:skip_college,"Skip")
		.transform('delete duplicative district 510',DeleteRows,:state_id,"510")
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3598: NC CSA'
		})
		.transform('Create date_valid field from year', WithBlock) do |row|
			if [2019,'2018-2019','2019'].include? row[:year]
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] = 2018
				row[:date_valid] = '2018-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('Remove quotation marks and commas from cohort_count', WithBlock) do |row|
			if row[:cohort_count] == 'NULL'
				row[:cohort_count] = row[:cohort_count]
			elsif row[:cohort_count] != 'NULL'
				row[:cohort_count] = row[:cohort_count].to_s.gsub(",","")
				row[:cohort_count] = row[:cohort_count].to_s.gsub("\"","")
			else
				row[:cohort_count] = 'Error'
			end
			row
		end
		.transform('Remove "%" symbol from values', WithBlock) do |row|
			row[:value] = row[:value].to_s.gsub("%","")
			row
		end
		.transform('delete blank values',DeleteRows,:value,nil)
		.transform('delete asterisk values',DeleteRows,:value,"*")
		.transform('delete period values',DeleteRows,:value,".")
		.transform('delete "  ." values',DeleteRows,:value,"  .")
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
		.transform('map grades', HashLookup, :data_type_id, map_grade, to: :grade)
	end


	def config_hash
	{
		source_id: 37,
        state: 'nc'
	}
	end
end

NCMetricsProcessor2019CSA.new(ARGV[0],max:nil).run