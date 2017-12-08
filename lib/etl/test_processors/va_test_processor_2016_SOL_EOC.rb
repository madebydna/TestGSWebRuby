require_relative "../test_processor"
GS::ETL::Logging.disable

class VATestProcessor2016SOL_EOC < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2016
	end

	map_breakdown_id = {
	'1' => 4,#native american or native alaskan
	'2' => 2,#asian
	'3' => 3,#black
	'4' => 6,#hispanic
	'5' => 8,#white
	'6' => 112,#Native Hawaiian or Other PI
	'99' => 21,#multiracial
	'NA' => 1
	}

	map_subject_id = {
	'English Reading' => 95,
	'Writing' => 3,
	'Geography' => 56,
	'VA & US History' => 96,
	'World History I' => 57,
	'World History II' => 58,
	'Algebra I' => 7,
	'Algebra II' => 11,
	'Geometry' => 9,
	'Biology' => 29,
	'Chemistry' => 42,
	'Earth Science' => 43,
	'Mathematics'=> 5,
	'Science'=> 25,
	'History'=> 97
	}

	map_prof_band_id ={
	pass_advanced_rate: 171,
	pass_prof_rate: 170,
	fail_rate: 169,
	pass_rate: 'null'
	} 

	source('va_sol_school.txt',[],col_sep:"\t") do |s|
		s.transform('entity level',Fill,{	
			entity_level: 'school'
		})
		.transform('state id',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row[:state_id] = row[:div_num].rjust(3,'0') + row[:sch_num].rjust(4,'0')
		row
		end
	end	

	source('va_sol_district.txt',[],col_sep:"\t") do |s|
		s.transform('entity level',Fill,{	
			entity_level: 'district'
		})
		.transform('state id',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row[:state_id] = row[:div_num].rjust(3,'0')
		row
		end
	end

	source('va_sol_state.txt',[],col_sep:"\t") do |s|
		s.transform('entity level',Fill,{	
			entity_level: 'state',
			state_id: 'state'
			})
	end

	shared do |s|
		s.transform('map breakdowns',HashLookup,:federal_race_code,map_breakdown_id,to: :breakdown_id)
		.transform('map subjects',HashLookup,:test, map_subject_id, to: :subject_id)
		.transform('rename fields',MultiFieldRenamer,
		 {
			federal_race_code: :breakdown,
			sch_name: :school_name,
			div_name: :district_name,
			sch_num: :school_id,
			div_num: :district_id,
			subject: :subject_group,
			test: :subject,
			total_cnt: :number_tested
		})
		.transform('test data type',WithBlock,) do |row|
			if row[:test_level] == 'EOC'
				row[:test_data_type] = 'VAEOC'
				row[:test_data_type_id] = 111
				row[:grade] = 'All'
			else
				row[:test_data_type] = 'SOL'
				row[:test_data_type_id] = 41
				row[:grade] = row[:test_level]
			end
			row
		end
		.transform('flags',WithBlock,) do |row|
			if row[:breakdown] == 'NA' && !row[:gender].nil? && row[:disability_flag].nil? && row[:lep_flag].nil? && row[:disadvantaged_flag].nil?
				if row[:gender] == 'F'
					row[:breakdown] = 'Female'
					row[:breakdown_id] = 11
				elsif row[:gender] == 'M'
					row[:breakdown] = 'Male'
					row[:breakdown_id] = 12
				end
			elsif row[:breakdown] == 'NA' && row[:gender].nil? && !row[:disability_flag].nil? && row[:lep_flag].nil? && row[:disadvantaged_flag].nil?
				if row[:disability_flag] == 'Y'
					row[:breakdown] = 'Students with disabilities'
					row[:breakdown_id] = 13
				elsif row[:disability_flag] == 'N'
					row[:breakdown] = 'General Education Students'
					row[:breakdown_id] = 14
				end
			elsif row[:breakdown] == 'NA' && row[:gender].nil? && row[:disability_flag].nil? && !row[:lep_flag].nil? && row[:disadvantaged_flag].nil?
				if row[:lep_flag] == 'Y'
					row[:breakdown] = 'Limited english proficient'
					row[:breakdown_id] = 15
				elsif row[:lep_flag] == 'N'
					row[:breakdown] = 'Not limited english proficient'
					row[:breakdown_id] = 16
				end
			elsif row[:breakdown] == 'NA' && row[:gender].nil? && row[:disability_flag].nil? && row[:lep_flag].nil? && !row[:disadvantaged_flag].nil?
				if row[:disadvantaged_flag] == 'Y'
					row[:breakdown] = 'Economically disadvantaged'
					row[:breakdown_id] = 9
				elsif row[:disadvantaged_flag] == 'N'
					row[:breakdown] = 'Not economically disadvantaged'
					row[:breakdown_id] = 10
				end
			end
			row
		end
		.transform('transpose prof bands',Transposer,:proficiency_band, :value_float,:pass_advanced_rate,:pass_prof_rate,:fail_rate,:pass_rate )
		.transform('map prof bands',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_id)
		.transform('',Fill,{
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			year: 2016
		})
	end

	def config_hash
		{
		source_id:27,
	        state: 'va',
		notes: 'DXT-1971 VA SOL, EOC 2016',
		url: '',
		file: 'va/2016/va.2016.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}		
	end

end

VATestProcessor2016SOL_EOC.new(ARGV[0],max:nil,offset:nil).run
