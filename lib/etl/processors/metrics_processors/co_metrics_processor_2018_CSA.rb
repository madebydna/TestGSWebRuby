require_relative '../../metrics_processor'

class COMetricsProcessor2018CSA < GS::ETL::MetricsProcessor

	def initialize(*args)
		super
		@year = 2018
		@ticket_n = 'DXT-3610'
	end

	map_breakdown_id = {
		'All Students' => 1
	}

	map_subject_id = {
		#grad
		'NA' => 0,
		#SAT
		'Any Subject' => 89,
		'math' => 5,
		'eng' => 17
	}

#college enrollment files
#state level
	source('state_college_enroll.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'state',
		subject: 'NA',
		date_valid: '2018-01-01 00:00:00',
		breakdown: 'All Students',
		data_type: 'college enrollment'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		collegeenrpct: :value
	})
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016','2017')
	end
#district level
	source('district_college_enroll.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		subject: 'NA',
		date_valid: '2018-01-01 00:00:00',
		breakdown: 'All Students',
		data_type: 'college enrollment'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		district: :district_name,
		collegeenrpct: :value
	})
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016','2017')
	.transform('delete bad districts',DeleteRows,:district_name,'NA')
	end
#school level
	source('school_college_enroll.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		subject: 'NA',
		date_valid: '2018-01-01 00:00:00',
		breakdown: 'All Students',
		data_type: 'college enrollment'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		district: :district_name,
		highschool: :school_name,
		collegeenrpct: :value
	})
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016','2017')
	.transform('delete bad schools',DeleteRows,:school_name,'Not in a school','NA')
	.transform('delete Yampah Mountain duplicate schools',DeleteRows,:state_id,'6134')
	end
#college persistence
#state level
	source('state_college_persist.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'state',
		data_type: 'college persistence',
		subject: 'NA',
		date_valid: '2018-01-01 00:00:00',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		persistyear2pct: :value
	})
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016','2018')
	end
#district level
	source('district_college_persist.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'college persistence',
		subject: 'NA',
		date_valid: '2018-01-01 00:00:00',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		district: :district_name,
		persistyear2pct: :value
	})
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016','2018')
	end
#school level
	source('school_college_persist.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'college persistence',
		subject: 'NA',
		date_valid: '2018-01-01 00:00:00',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		district: :district_name,
		highschool: :school_name,
		persistyear2pct: :value
	})
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016','2018')
	end
#college remediation
#state level
	source('state_college_remediation.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'state',
		state_id: 'state',
		data_type: 'college remediation',
		date_valid: '2017-01-01 00:00:00',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year
	})
	.transform('Transpose wide subgroups into long',Transposer,
		:subject_data_type,:value,
		:developmentalneedpct,:math_devneedpct,:eng_devneedpct
		)
	.transform('Assign subject name', WithBlock) do |row|
		if row[:subject_data_type] == :developmentalneedpct
			row[:subject] = 'Any Subject'
		elsif row[:subject_data_type] != :developmentalneedpct
			m = row[:subject_data_type].match /^([a-z]+)_devneedpct$/
			row[:subject] = m[1]
		else
			row[:subject] = 'Error'
		end
		row
	end
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016')
	end
#district level
	source('district_college_remediation.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'district',
		data_type: 'college remediation',
		date_valid: '2017-01-01 00:00:00',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		hs_districtcode: :district_id,
		hs_districtname: :district_name
	})
	.transform('Assign state_id', WithBlock) do |row|
		row[:state_id] = row[:district_id].rjust(4,'0')
		row
	end
	.transform('Transpose wide subgroups into long',Transposer,
		:subject_data_type,:value,
		:developmentalneedpct,:math_devneedpct,:eng_devneedpct
		)
	.transform('Assign subject name', WithBlock) do |row|
		if row[:subject_data_type] == :developmentalneedpct
			row[:subject] = 'Any Subject'
		elsif row[:subject_data_type] != :developmentalneedpct
			m = row[:subject_data_type].match /^([a-z]+)_devneedpct$/
			row[:subject] = m[1]
		else
			row[:subject] = 'Error'
		end
		row
	end
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016')
	end
#school level
	source('school_college_remediation.txt',[],col_sep:"\t") do |s|
	s.transform('Fill missing default fields', Fill, {
		entity_type: 'school',
		data_type: 'college remediation',
		date_valid: '2017-01-01 00:00:00',
		breakdown: 'All Students'
	})
	.transform('rename columns',MultiFieldRenamer, {
		hs_gradyear: :year,
		hs_districtcode: :district_id,
		hs_districtname: :district_name,
		hs_code_cde: :school_id,
		hs_name: :school_name
	})
	.transform('Assign state_id', WithBlock) do |row|
		row[:state_id] = row[:school_id].rjust(4,'0')
		row
	end
	.transform('Transpose wide subgroups into long',Transposer,
		:subject_data_type,:value,
		:developmentalneedpct,:math_devneedpct,:eng_devneedpct
		)
	.transform('Assign subject name', WithBlock) do |row|
		if row[:subject_data_type] == :developmentalneedpct
			row[:subject] = 'Any Subject'
		elsif row[:subject_data_type] != :developmentalneedpct
			m = row[:subject_data_type].match /^([a-z]+)_devneedpct$/
			row[:subject] = m[1]
		else
			row[:subject] = 'Error'
		end
		row
	end
	.transform('delete unwanted year values',DeleteRows,:year,'2009','2010','2011','2012','2013','2014','2015','2016')
	end

	shared do |s|
		s.transform('fill other columns',Fill,{
			notes: 'DXT-3610: CO CSA',
			grade: 'NA'
		})
		.transform('Assign data type ids and cohort counts', WithBlock) do |row|
			if row[:data_type] == 'college enrollment'
				row[:cohort_count] = nil
				row[:data_type_id] = 412
			elsif row[:data_type] == 'college persistence'
				row[:data_type_id] = 409
				if row[:entity_type] == 'state'
					row[:cohort_count] = row[:enrincollege]
				elsif ['district','school'].include? row[:entity_type]
					row[:cohort_count] = nil
				end
			elsif row[:data_type] == 'college remediation'
				row[:data_type_id] = 413
				row[:cohort_count] = row[:devcollegeenrollee]
			else
				row[:data_type_id] = 'Error'
				row[:cohort_count] = 'Error'
			end
			row
		end
		.transform('delete bad values',DeleteRows,:value,nil,'*')
		.transform('Adjust values and cohort counts to remove quotes, commas, and '%' symbols', WithBlock) do |row|
			row[:value] = (row[:value].to_f * 100).round(6)
			row[:cohort_count] = row[:cohort_count].to_s.gsub("\"","").gsub(",","").gsub(" ","")
			if row[:cohort_count].nil? || row[:cohort_count] == ''
				row[:cohort_count] = 'NULL'
			else
				row[:cohort_count] = row[:cohort_count]
			end
			row
		end
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
	end


	def config_hash
	{
		source_id: 70,
		state: 'co'
	}
	end
end

COMetricsProcessor2018CSA.new(ARGV[0],max:nil).run
