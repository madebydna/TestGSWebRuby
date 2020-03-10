require_relative "../test_processor"
GS::ETL::Logging.disable

class GATestProcessor2016Milestones < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2016
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
	#'Migrant' =>
	#'Non-Migrant' => 
	'Two or More Races' => 21,
	'Asian' => 2,
	'Limited English Proficient' => 15,
	'American Indian or Alaskan Native' => 4,
	'Native Hawaiian or Other Pacific Islander' => 112
	}

	map_proficiency_band_id = {
	:begin_pct => 26,
	:developing_pct => 27,
	:proficient_pct => 28,
	:distinguished_pct => 29,
	:prof_null => 'null'
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

	source('EOC_2016_DEC_1st_2016.csv',[],col_sep:',') do |s|
		s.transform('data type',Fill,{
		test_data_type: 'MileStonesEOC',
		test_data_type_id: 241,
		grade: 'All'
		})
	end

	source('EOG_2016_By_Grad_DEC_1st_2016.csv',[],col_sep:',') do |s|
		s.transform('data type',Fill,{
		test_data_type: 'MileStonesEOG',
		test_data_type_id: 242
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
			elsif row[:school_id] == 'ALL' && row[:district_id] != 'ALL'
			       row[:entity_level] = 'district'
			       row[:state_id] = row[:district_id]
			elsif row[:school_id] != 'ALL' && row[:district_id] != 'ALL'
			 	row[:entity_level] = 'school'
				if row[:district_id].length == 3
					row[:state_id] = "%s%04s" % [row[:district_id],row[:school_id]]
				elsif row[:district_id].length == 7
					row[:state_id] = row[:district_id]
				end
			end	
			row	
		end
		.transform('prof null',WithBlock) do |row|
			row[:prof_null] = (row[:proficient_pct].to_f + row[:distinguished_pct].to_f).round(4)
		row
		end
		.transform('transpose proficiency band ids',Transposer,:proficiency_band,:value_float,:begin_pct,:developing_pct,:proficient_pct,:distinguished_pct,:prof_null)
		.transform('breakdown id',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('proficiency band id',HashLookup, :proficiency_band, map_proficiency_band_id,to: :proficiency_band_id)
		.transform('',Fill,{
			year: 2016,
			entity_type: 'public,charter',
			level_code: 'e,m,h'
		})
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row[:grade] = row[:grade].to_s.sub(/^[ 0]+/,'')
			row
		end
	end

	def config_hash
		{
		source_id: 86,
		state: 'ga',
		notes: 'DXT-1897 GA Test 2016',
		url: 'https://gosa.georgia.gov/downloadable-data',
		file: 'ga/2016/ga.2016.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

GATestProcessor2016Milestones.new(ARGV[0],max:nil,offset:nil).run
