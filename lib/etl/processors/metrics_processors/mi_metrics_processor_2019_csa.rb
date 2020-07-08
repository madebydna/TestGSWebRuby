require 'set'
require_relative '../../metrics_processor'

class MIMetricsProcessor2019CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2019
		@ticket_n = 'DXT-3581'
	end

	map_subject_id = {
	'Composite' => 1,
	'EBRW' => 2,
	'Math' => 5,
	'Reading' => 2,
	'Writing' => 3,
	'Science' => 19,
	'Any Subject' => 89,
	'NA' => 0
	}

	map_breakdown_id = {
	'All Students' => 1,
	'African American' => 17,
	'Black, not of Hispanic origin' => 17,
	'American Indian or Alaska Native' => 18,
	'Asian' => 16,
	'Economically Disadvantaged' => 23,
	'Not Economically Disadvantaged' => 24,
	'English Learners' => 32,
	'English Language Learners' => 32,
	'Not English Language Learners' => 33,
	'Hispanic/Latino' => 19,
	'Hispanic' => 19,
	'Native Hawaiian or Other Pacific Islander' => 20,
	'Students With Disabilities' => 27,
	'Students with Disabilities' => 27,
	'Students without IEP' => 30,
	'Two or More Races' => 22,
	'White' => 21,
	'White, not of Hispanic origin' => 21,
	'Male' => 25,
	'Female' => 26
	}

	map_grade = {
	446 => 'All',
	442 => 'All',
	443 => 'NA',
	476 => 'NA',
	478 => 'NA',
	485 => 'NA',
	409 => 'NA',
	413 => 'NA'
	}

	source('2019_MI_graduation.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		data_type: 'graduation rate',
		data_type_id: 443,
		subject: 'NA',
		year: '2019'
	})
	.transform('rename columns',MultiFieldRenamer, {
		districtcode: :district_id,
		districtname: :district_name,
		buildingcode: :school_id,
		buildingname: :school_name,
		entitytype: :entity_type,
		cohortyear: :year,
		cohortcount: :cohort_count,
		graduationrate: :value
	})
	.transform('skip 5-Year cohort', DeleteRows, :rateyear, '5-Year')
	.transform('skip 6-Year cohort', DeleteRows, :rateyear, '6-Year')
	.transform('Manually identify schools with duplicated data across different districts', WithBlock) do |row| 
	#better iteration would have logic to identify more than 1 district id per school id
		if ['00052','00070','00394','00405','00449','00682','00800','01059','01813','02082','02231','07704','08403','09886','01086','01515','01807','01901','02432','05690','06503','07871','09927'].include? row[:school_id]
			row[:duplicate_entry] = 'Yes'
		else
			row[:duplicate_entry] = 'No'
		end
		row
	end
	.transform('Skip duplicate entries per school id', DeleteRows, :duplicate_entry, 'Yes')
	end
	source('2019_MI_SAT.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		year: 2019
	})
	.transform('rename columns',MultiFieldRenamer, {
		districtcode: :district_id,
		districtname: :district_name,
		buildingcode: :school_id,
		buildingname: :school_name,
		entitytype: :entity_type,
		subgroup: :breakdown
	})
	.transform('Transpose subject columns for values to load', 
	Transposer, 
		:datatype_subject,:value,
		:allsubjectscoreaverage, :ebrwscoreaverage,
		:mathscoreaverage, :allsubjectpercentready,
		:ebrwpercentready, :mathpercentready
	)
	.transform('Adjust sat data types', WithBlock) do |row|
		if [:allsubjectscoreaverage, :ebrwscoreaverage,:mathscoreaverage].include? row[:datatype_subject]
			row[:data_type] = 'SAT average score'
			row[:data_type_id] = 446
			if row[:datatype_subject] == :allsubjectscoreaverage
				row[:subject] = 'Composite'
			elsif row[:datatype_subject] == :ebrwscoreaverage
				row[:subject] = 'EBRW'
			elsif row[:datatype_subject] == :mathscoreaverage
				row[:subject] = 'Math'
			end
		elsif [:allsubjectpercentready,:ebrwpercentready, :mathpercentready].include? row[:datatype_subject]
			row[:data_type] = 'SAT percent college ready'
			row[:data_type_id] = 442
			if row[:datatype_subject] == :allsubjectpercentready
				row[:subject] = 'Composite'
			elsif row[:datatype_subject] == :ebrwpercentready
				row[:subject] = 'EBRW'
			elsif row[:datatype_subject] == :mathpercentready
				row[:subject] = 'Math'
			end
		end
		row
	end
	.transform('Assign cohort count by subject', WithBlock) do |row|
		if row[:subject] == 'Composite'
			row[:cohort_count] = row[:allsubjectnumassessed]
		elsif row[:subject] == 'EBRW'
			row[:cohort_count] = row[:ebrwnumassessed]
		elsif row[:subject] == 'Math'
			row[:cohort_count] = row[:mathnumassessed]
		else
			row[:cohort_count] = 'Error'
		end
		row
	end
	.transform('skip "*" values cohorts', DeleteRows, :value, '*')
	end
	source('2019_MI_ps_enrollment.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		year: 2019,
		subject: 'NA'
	})
	.transform('rename columns',MultiFieldRenamer, {
		districtcode: :district_id,
		districtofficialname: :district_name,
		buildingcode: :school_id,
		buildingofficialname: :school_name,
		entitytype: :entity_type,
		total_graduates_all_students: :cohort_count,
		total__enrolled_in_an_ihe_within_06_months: :value
	})
	.transform('Assign data type id', WithBlock) do |row|
		if row[:ihe_type] == 'All'
			row[:data_type] = 'overall enrollment'
			row[:data_type_id] = 485
		elsif row[:ihe_type] == 'Four Year'
			row[:data_type] = '4 year enrollment'
			row[:data_type_id] = 478
		elsif row[:ihe_type] == 'Two Year'
			row[:data_type] = '2 year enrollment'
			row[:data_type_id] = 476
		else
			row[:data_type] = 'Error'
			row[:data_type_id] = 'Error'
		end
		row
	end
	end
	source('2019_MI_ps_persistence.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		subject: 'NA',
		year: 2019,
		data_type: 'college persistence',
		data_type_id: 409
	})
	.transform('rename columns',MultiFieldRenamer, {
		districtcode: :district_id,
		districtname: :district_name,
		buildingcode: :school_id,
		buildingname: :school_name,
		entitytype: :entity_type,
		report_category: :breakdown,
		total_count: :cohort_count,
		continuing_in_college_percent: :value
	})
	.transform('skip bad years', DeleteRows, :school_year, '17 - 18 School Year')
	.transform('skip "< 10" values', DeleteRows, :value, '< 10')
		.transform('Manually identify schools with duplicated data across different districts', WithBlock) do |row| 
		#better iteration would have logic to identify more than 1 district id per school id
		if ['00052','00682','01059','08403','09886','00449','00405','02644'].include? row[:school_id]
			row[:duplicate_entry] = 'Yes'
		else
			row[:duplicate_entry] = 'No'
		end
		row
	end
	.transform('Skip duplicate entries per school id', DeleteRows, :duplicate_entry, 'Yes')
	end
	source('2018_MI_ps_remedial.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		year: 2018,
		data_type: 'college remediation',
		data_type_id: 413
	})
	.transform('rename columns',MultiFieldRenamer, {
		districtcode: :district_id,
		districtofficialname: :district_name,
		buildingcode: :school_id,
		buildingofficialname: :school_name,
		entitytype: :entity_type,
		total_enrolled_in_an_ihe: :cohort_count
	})
	.transform('Transpose subject columns for values to load', 
	Transposer, 
		:datatype_subject,:value,
		:total__enrolled_in_remedial_coursework__math, :total__enrolled_in_remedial_coursework__reading,
		:total__enrolled_in_remedial_coursework__writing, :total__enrolled_in_remedial_coursework__science,
		:total__enrolled_in_remedial_coursework__any_subject
	)
	.transform('Create subject field', WithBlock) do |row|
		if row[:datatype_subject] == :total__enrolled_in_remedial_coursework__math
			row[:subject] = 'Math'
		elsif row[:datatype_subject] == :total__enrolled_in_remedial_coursework__reading
			row[:subject] = 'Reading'
		elsif row[:datatype_subject] == :total__enrolled_in_remedial_coursework__writing
			row[:subject] = 'Writing'
		elsif row[:datatype_subject] == :total__enrolled_in_remedial_coursework__science
			row[:subject] = 'Science'
		elsif row[:datatype_subject] == :total__enrolled_in_remedial_coursework__any_subject
			row[:subject] = 'Any Subject'
		else
			row[:subject] = 'Error'
		end
		row
	end
	.transform('skip 2 year cohorts values', DeleteRows, :ihe_type, '2Y_IN_PUB')
	.transform('skip 4 year cohorts values', DeleteRows, :ihe_type, '4Y_IN_PUB')
	.transform('skip bad values', DeleteRows, :value, '<10')
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3581: MI CSA'
		})
		.transform('Create date_valid based on year', WithBlock) do |row|
			if [2019,'2019'].include? row[:year]
				row[:date_valid] = '2019-01-01 00:00:00'
			elsif row[:year] == 2018
				row[:date_valid] = '2018-01-01 00:00:00'
			else
				row[:date_valid] = 'Error'
			end
			row
		end
		.transform('transform breakdowns for double disagg data and identify unneeded breakdowns', WithBlock) do |row|
			if ['graduation rate','overall enrollment','4 year enrollment','2 year enrollment','college remediation'].include? row[:data_type]
				if ['overall enrollment','4 year enrollment','2 year enrollment'].include? row[:data_type]
					if ['Male','Female'].include? row[:gender]
						if row[:subgroup] == 'All Students'
							row[:breakdown] = row[:gender]
						else
							row[:breakdown] = 'Skip'
						end
					elsif row[:gender] == 'All Students'
						if ['Homeless','Migrant'].include? row[:subgroup]
							row[:breakdown] = 'Skip'
						else
							row[:breakdown] = row[:subgroup]
						end
					end
				elsif ['college remediation'].include? row[:data_type]
					if ['Male','Female'].include? row[:gender]
						if row[:subgroup] == row[:gender]
							row[:breakdown] = row[:gender]
						else
							row[:breakdown] = 'Skip'
						end
					elsif row[:gender] == 'All Students'
						if ['Homeless','Migrant'].include? row[:subgroup]
							row[:breakdown] = 'Skip'
						else
							row[:breakdown] = row[:subgroup]
						end
					end
				elsif ['graduation rate'].include? row[:data_type]
					if row[:crosstabs] == 'All Students'
						if ['Early Middle College','Foster Care','Homeless','Migrant','Military Connected'].include? row[:subgroup]
							row[:breakdown] = 'Skip'
						else
						row[:breakdown] = row[:subgroup]
						end
					elsif row[:crosstabs] != 'All Students'
						row[:breakdown] = 'Skip'
					else
						row[:breakdown] = 'Error'
					end
				end
			elsif ['SAT percent college ready','SAT average score','college persistence'].include? row[:data_type]
				if ['Foster Care','Homeless','Migrant','Military Connected','Not Foster Care','Not Homeless','Not Migrant','Not Military Connected'].include? row[:breakdown]
					row[:breakdown] = 'Skip'
				else
					row[:breakdown] = row[:breakdown]
				end
			else
				row[:breakdown] = row[:breakdown]
			end
			row
		end
		.transform('skip "Skip" breakdowns', DeleteRows, :breakdown, 'Skip')
		.transform('assign entity type', WithBlock) do |row|
			if row[:entity_type] == 'State'
				row[:entity_type] = 'state'
			elsif ['PSA District', 'LEA District', 'ISD District', 'State District'].include? row[:entity_type]
				row[:entity_type] = 'district'
			elsif ['PSA School', 'LEA School', 'ISD School', 'State School'].include? row[:entity_type]
				row[:entity_type] = 'school'
			elsif ['ISD Unique Education Provider', 'LEA Unique Education Provider', 'State Unique Education Provider','ISD'].include? row[:entity_type]
				row[:entity_type] = 'Skip'
			else
				row[:entity_type] = 'Error'
			end
			row
		end
		.transform('skip "Skip" entity types', DeleteRows, :entity_type, 'Skip')
		.transform('Create state_id field', WithBlock) do |row|
			if row[:entity_type] == 'state'
				row[:state_id] = 'state'
			elsif row[:entity_type] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_type] == 'school'
				row[:state_id] = row[:school_id]
			else
				row[:state_id] = 'Error'
			end
			row
		end
		.transform('Adjust values and cohort counts to deal with inequalities', WithBlock) do |row|
			row[:value] = row[:value].gsub("%","")
			row[:cohort_count] = row[:cohort_count].to_s.gsub("<10","NULL")
			if ['SAT average score','SAT percent college ready'].include? row[:data_type]
				if ['<=20','<=5','<=50','<=10','>=50','>=80','>=90','>=95'].include? row[:value]
					row[:value] = 'N/A'
				else
					row[:value] = row[:value]
				end
			end
			row
		end
		.transform('skip "N/A" values', DeleteRows, :value, 'N/A')
		.transform('trim decimal values to 2 places', WithBlock) do |row|
			if ['<5','>95','<=1','>=99'].include? row[:value]
				row[:value] = row[:value]
			else
				row[:value] = sprintf('%.2f',row[:value])
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map grades',HashLookup,:data_type_id, map_grade,to: :grade)
	end

	def config_hash
	{
		source_id: 26,
		state: 'mi'
	}
	end
end

MIMetricsProcessor2019CSA.new(ARGV[0],max:nil).run