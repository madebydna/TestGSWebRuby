require_relative "../test_processor"

class GATestProcessor2018Milestones < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2018
	end

	map_breakdown_id = {
	'All Students' => 1,
	'Male' => 25,
	'Female' => 26,
	'Black or African American' => 17,
	'White' => 21,
	'Hispanic' => 19,
	'Students with Disabilities' => 27,
	'Students without Disabilities' => 30,
	'Not Limited English Proficient' => 33,
	'Economically Disadvantaged' => 23,
	'Not Economically Disadvantaged' => 24,
	'Two or More Races' => 22,
	'Asian' => 16,
	'Limited English Proficient' => 32,
	'American Indian or Alaskan Native' => 18,
	'Native Hawaiian or Other Pacific Islander' => 20
	}

	map_proficiency_band_id = {
	:begin_pct => 51,
	:developing_pct => 52,
	:proficient_pct => 53,
	:distinguished_pct => 54,
	:prof_above => 1
	}

	map_subject_id = {
	'English Language Arts' => 4,
	'Mathematics' => 5,
	'Science' => 19,
	'Social Studies' => 18,
	'9th Grade Literature and Composition' => 25,
	'Algebra I' => 6,
	'American Literature and Composition' => 26,
	'Analytic Geometry' => 69,
	'Biology' => 22,
	'Economics/Business/Free Enterprise' => 41,
	'Physical Science' => 24,
	'US History' => 23,
	'Coordinate Algebra' => 63,
	'Geometry' => 8
	}

	source('EOC_2018_DEC_28th_2018.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		test_data_type: 'GA Milestones EOC',
		test_data_type_id: 303,
		notes: 'DXT-3345: GA MileStones EOC',
		description: 'In 2017-2018, students in Georgia took the George Milestones Assessment. The Georgia Milestones Assessment System (Georgia Milestones) is a comprehensive summative assessment pro​gram spanning grades 3 through high school. Georgia Milestones measures how well students have learned the knowledge and skills outlined in the state-adopted content standards in English Language Arts, mathematics, science, and social studies. Students in grades 3 through 8 take an end-of-grade assessment in English Language Arts and mathematics while students in grades 5 and 8 are also assessed in science and social studies. High school students take an end-of-course assessment for each of the ten courses designated by the State Board of Education.',
		grade: 'All'
		})
	end

	source('EOG_2018_DEC_28th_2018.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		test_data_type: 'GA Milestones EOG',
		test_data_type_id: 304,
		notes: 'DXT-3345: GA MileStones EOG',
		description: 'In 2017-2018, students in Georgia took the George Milestones Assessment. The Georgia Milestones Assessment System (Georgia Milestones) is a comprehensive summative assessment pro​gram spanning grades 3 through high school. Georgia Milestones measures how well students have learned the knowledge and skills outlined in the state-adopted content standards in English Language Arts, mathematics, science, and social studies. Students in grades 3 through 8 take an end-of-grade assessment in English Language Arts and mathematics while students in grades 5 and 8 are also assessed in science and social studies. High school students take an end-of-course assessment for each of the ten courses designated by the State Board of Education.',
		grade: 'All'
		})
	end
		
	source('EOG_2018_By_Grad_DEC_28th_2018.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		test_data_type: 'GA Milestones EOG',
		test_data_type_id: 304,
		notes: 'DXT-3345: GA MileStones EOG',
		description: 'In 2017-2018, students in Georgia took the George Milestones Assessment. The Georgia Milestones Assessment System (Georgia Milestones) is a comprehensive summative assessment pro​gram spanning grades 3 through high school. Georgia Milestones measures how well students have learned the knowledge and skills outlined in the state-adopted content standards in English Language Arts, mathematics, science, and social studies. Students in grades 3 through 8 take an end-of-grade assessment in English Language Arts and mathematics while students in grades 5 and 8 are also assessed in science and social studies. High school students take an end-of-course assessment for each of the ten courses designated by the State Board of Education.'
		})
		.transform('fix grade',WithBlock) do |row|
			row[:acdmc_lvl] = row[:acdmc_lvl][1..-1]
		row
		end
	end

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			school_distrct_cd: :district_id,
			school_dstrct_nm: :district_name,
			instn_number: :school_id,
			instn_name: :school_name,
			subgroup_name: :breakdown,
			test_cmpnt_typ_nm: :subject,
			num_tested_cnt: :number_tested,
			acdmc_lvl: :grade,
		})
		.transform('n tested < 10',DeleteRows,:number_tested,'1','2','3','4','5','6','7','8','9')
		.transform('skip migrant subgroups',DeleteRows,:breakdown,'Migrant','Non-Migrant','Homeless','Active Duty')
		.transform('entity level',WithBlock,) do |row|
			if (row[:school_id] == 'ALL' && row[:district_id] == 'ALL') || (row[:school_name] == 'ALL' && row[:district_name] == 'ALL')
				row[:entity_type] = 'state'
				row[:state_id] = 'state'
				row[:school_id] = 'state'
				row[:district_id] = 'state'
			elsif row[:school_id] == 'ALL' && row[:district_id] != 'ALL'
			       row[:entity_type] = 'district'
			       row[:state_id] = row[:district_id]
			       row[:school_id] = 'district'
			elsif row[:school_id] != 'ALL' && row[:district_id] != 'ALL'
			 	row[:entity_type] = 'school'
				if row[:district_id].length == 3
					row[:state_id] = row[:district_id].to_s + row[:school_id].rjust(4,'0').to_s
				elsif row[:district_id].length == 7
					row[:state_id] = row[:district_id]
				end
				row[:school_id] = row[:state_id]
			end	
			row	
		end
		.transform('prof and above',WithBlock) do |row|
			row[:prof_above] = ((row[:proficient_pct].to_f + row[:distinguished_pct].to_f).round(4)).to_s
			row
		end
		.transform('transpose proficiency band ids',Transposer,:proficiency_band,:value,:begin_pct,:developing_pct,:proficient_pct,:distinguished_pct,:prof_above)
		.transform('breakdown id',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('proficiency band id',HashLookup, :proficiency_band, map_proficiency_band_id,to: :proficiency_band_id)
		.transform('fill default year and date valid',Fill,{
			year: 2018,
			date_valid: '2018-01-01 00:00:00'

		})

	end

	def config_hash
		{
		source_id: 14,
		state: 'ga',
		}
	end

end

GATestProcessor2018Milestones.new(ARGV[0],max:nil).run
