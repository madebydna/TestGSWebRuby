require_relative '../test_processor'
GS::ETL::Logging.disable

class MITestProcessor2016MSTEP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year = 2016
	end

	map_breakdown_id = {
	'All Students' => 1,
	'Students with Disabilities' => 13,
	'All Except Students with Disabilities' => 14,#general ed
	'American Indian or Alaska Native' => 4,
	'Asian' => 2,
	'Black or African American' => 3,
	'Female' => 11,
	'Hispanic or Latino' => 6,
	'Native Hawaiian or Other Pacific Islander' => 112,
	'Two or More Races' => 21,
	'White' => 8,
	'Male' => 12,
	'Economically Disadvantaged' => 9,
	'English Learners' => 15,
	#'Homeless' => ,
	#'Formerly English Learners' => ,
	}

	map_subject_id = {
	'English Language Arts' => 4,
	'Mathematics' => 5,
	'Social Studies' => 24,
	'Science' => 25
	}

	source('Spring 2016 M-STEP and MME Two year Public Demographic Detail Sortable_292017.txt',[],col_sep:"\t")

	shared do |s|
		s.transform('Delete SAT subjects',DeleteRows,:subject,/SAT/)
		.transform('skip subgroups',DeleteRows,:demographicgroup, 'Homeless','Formerly English Learners')
		.transform('grade 12',DeleteRows,:grade, '12')
		.transform('rename columns',MultiFieldRenamer,{
			percent_advancedproficient_2016: :value_float,
			demographicgroup: :breakdown,
			buildingcode: :school_id,
			buildingname: :school_name,
			districtcode: :district_id,
			districtname: :district_name,
			total_valid_2016: :number_tested
		})
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
		.transform('state ids and entity level',WithBlock,) do |row|
			if row[:school_id] == '0' && row[:district_id] != '0'
				row[:entity_level] = 'district'
				row[:state_id] = row[:district_id].rjust(5,'0')
			elsif row[:school_id] != '0' && row[:district_id] != '0'
				row[:entity_level] = 'school'
				row[:state_id] = row[:school_id].rjust(5,'0')
			elsif row[:school_id] == '0' && row[:district_id] == '0' 
				if row[:isdname] == 'Statewide'
					row[:entity_level] = 'state'
					row[:state_id] = 'state' 
				elsif row[:isdname] != 'Statewide'
			       		row[:entity_level] = '*'
				end
			end
			#row[:school_name] = row[:school_name].gsub('Edward "Duke" Ellington','Edward Duke Ellington')
			#require 'byebug'
			#byebug
			row
		end
		.transform('delete isd rows',DeleteRows,:entity_level,'*')
		.transform('delete n < 10',DeleteRows,:number_tested,'<10',nil)
		.transform('change inequalities to negative',WithBlock) do |row|
			case row[:value_float]
			when '<=5%'
				row[:value_float] = '-5'
			when '<=10%'
				row[:value_float] = '-10'
			when '>=90%'
				row[:value_float] = '-90'
			when '>=95%'
				row[:value_float] = '-95'
		
			end
			row
		end
		.transform('map breakdowns',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('fill other columns',Fill,{
		year: 2016,
		entity_type: 'public_charter',
		test_data_type: 'M-STEP',
		test_data_type_id: 245,
	       	level_code: 'e,m,h',
		proficiency_band_id: 'null'	
		})
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row[:grade] = row[:grade].to_s.sub(/^[0]+/,'')	
			row
		end
	end
	

	def config_hash
	{
		source_id: 9,
		state: 'mi',
		notes: 'DXT-1968 MI MSTEP 2016',
		url: 'http://www.michigan.gov/mde/',
		file: 'mi/2016/mi.2016.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
	}
	end
end

MITestProcessor2016MSTEP.new(ARGV[0],max:nil,offset:nil).run
