require_relative "../test_processor"
GS::ETL::Logging.disable

class GATestProcessor2017Milestones < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2017
	end

	map_breakdown_id = {
	'All Students' => 1,
	'Male' => 12,
	'Female' => 11,
	'Black or African American' => 3,
	'White' => 8,
	'Hispanic' => 6,
	'Students with Disabilities' => 13,
	'Students without Disabilities' => 14,
	'Not Limited English Proficient' => 16,
	'Economically Disadvantaged' => 9,
	'Not Economically Disadvantaged' => 10,
	'Two or More Races' => 21,
	'Asian' => 2,
	'Limited English Proficient' => 15,
	'American Indian or Alaskan Native' => 4,
	'Native Hawaiian or Other Pacific Islander' => 112
	}

	map_gsdata_breakdown_id = {
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
	:begin_pct => 26,
	:developing_pct => 27,
	:proficient_pct => 28,
	:distinguished_pct => 29,
	:prof_null => 'null'
	}

	map_gsdata_proficiency_band_id = {
	:begin_pct => 51,
	:developing_pct => 52,
	:proficient_pct => 53,
	:distinguished_pct => 54,
	:prof_null => 1
	}

	map_subject_id = {
	'English Language Arts' => 4,
	'Mathematics' => 5,
	'Science' => 25,
	'Social Studies' => 24,
	'9th Grade Literature and Composition' => 32,
	'Algebra I' => 7,
	'American Literature and Composition' => 33,
	'Analytic Geometry' => 84,
	'Biology' => 29,
	'Economics/Business/Free Enterprise' => 54,
	'Physical Science' => 31,
	'US History' => 30,
	'Coordinate Algebra' => 78,
	'Geometry' => 9
	}

	map_gsdata_academic_id = {
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

	source('ga_eoc_2017_test.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		test_data_type: 'MileStonesEOC',
		test_data_type_id: 241,
		gsdata_test_data_type_id: 303,
		notes: 'DXT-2555: GA MileStones EOC',
		description: 'In 2016-2017, students in Georgia took the George Milestones Assessment. The Georgia Milestones Assessment System (Georgia Milestones) is a comprehensive summative assessment program spanning grades 3 through high school. Georgia Milestones measures how well students have learned the knowledge and skills outlined in the state-adopted content standards in language arts, mathematics, science, and social studies. Students in grades 3 through 8 will take an end-of-grade assessment in each content area, while high school students will take an end-of-course assessment for each of the eight courses designated by the State Board of Education.',
		grade: 'All'
		})
	end

	source('ga_eog_2017_test.txt',[],col_sep:"\t") do |s|
		s.transform('data type',Fill,{
		test_data_type: 'MileStonesEOG',
		test_data_type_id: 242,
		gsdata_test_data_type_id: 304,
		notes: 'DXT-2555: GA MileStones EOG',
		description: 'In 2016-2017, students in Georgia took the George Milestones Assessment. The Georgia Milestones Assessment System (Georgia Milestones) is a comprehensive summative assessment program spanning grades 3 through high school. Georgia Milestones measures how well students have learned the knowledge and skills outlined in the state-adopted content standards in language arts, mathematics, science, and social studies. Students in grades 3 through 8 will take an end-of-grade assessment in each content area, while high school students will take an end-of-course assessment for each of the eight courses designated by the State Board of Education.'
		})
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
		.transform('skip migrant subgroups',DeleteRows,:breakdown,'Migrant','Non-Migrant')
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row
		end
		.transform('entity level',WithBlock,) do |row|
			if row[:school_id] == 'ALL' && row[:district_id] == 'ALL'
				row[:entity_level] = 'state'
				row[:state_id] = 'state'
				row[:school_id] = 'state'
				row[:district_id] = 'state'
			elsif row[:school_id] == 'ALL' && row[:district_id] != 'ALL'
			       row[:entity_level] = 'district'
			       row[:state_id] = row[:district_id]
			       row[:school_id] = 'district'
			elsif row[:school_id] != 'ALL' && row[:district_id] != 'ALL'
			 	row[:entity_level] = 'school'
				if row[:district_id].length == 3
					row[:state_id] = row[:district_id].to_s + row[:school_id].rjust(4,'0').to_s
				elsif row[:district_id].length == 7
					row[:state_id] = row[:district_id]
				end
				row[:school_id] = row[:state_id]
			end	
			row	
		end
		.transform('prof null',WithBlock) do |row|
			row[:prof_null] = ((row[:proficient_pct].to_f + row[:distinguished_pct].to_f).round(4)).to_s
		row
		end
		.transform('transpose proficiency band ids',Transposer,:proficiency_band,:value_float,:begin_pct,:developing_pct,:proficient_pct,:distinguished_pct,:prof_null)
		.transform('breakdown id',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('breakdown id',HashLookup,:breakdown,map_gsdata_breakdown_id,to: :breakdown_gsdata_id)
		.transform('subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('academic ids',HashLookup,:subject, map_gsdata_academic_id,to: :academic_gsdata_id)
		.transform('proficiency band id',HashLookup, :proficiency_band, map_proficiency_band_id,to: :proficiency_band_id)
		.transform('proficiency band id',HashLookup, :proficiency_band, map_gsdata_proficiency_band_id,to: :proficiency_band_gsdata_id)
		.transform('',Fill,{
			year: 2017,
			entity_type: 'public,charter',
			level_code: 'e,m,h'
		})
		# .transform('',WithBlock,) do |row|
		# 	#require 'byebug'
		# 	#byebug
		# 	row[:grade] = row[:grade].to_s.sub(/^[ 0]+/,'')
		# 	row
		# end
	end

	def config_hash
		{
		source_id: 86,
		source_name: 'Georgia Governor\'s Office of Student Achievement',
		date_valid: '2017-01-01 00:00:00',
		state: 'ga',
		url: 'https://gosa.georgia.gov/downloadable-data',
		file: 'ga/2017/ga.2017.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

GATestProcessor2017Milestones.new(ARGV[0],max:nil,offset:nil).run
