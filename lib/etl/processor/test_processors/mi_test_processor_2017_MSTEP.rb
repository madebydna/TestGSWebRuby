require_relative '../test_processor'
GS::ETL::Logging.disable

class MITestProcessor2017MSTEP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year = 2017
	end

	map_breakdown_id = {
		'All Students' => 1,
		'Students with Disabilities' => 13,
		'All Except Students with Disabilities' => 14,
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
		'English Language Learners' => 15
	}

	map_subject_id = {
		'English Language Arts' => 4,
		'Mathematics' => 5,
		'Social Studies' => 24,
		'Science' => 25
	}

	source('2017_mstep.txt',[],col_sep:"\t")

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,{
			demographicgroup: :breakdown,
			buildingcode: :school_id,
			buildingname: :school_name,
			districtcode: :district_id,
			districtname: :district_name,
			total_valid_mstep_only_2017: :number_tested,
			percent_advanced_proficient_mstep_only_2017: :value_float,
			contentareaname: :subject
		})
		.transform('Delete SAT subjects',DeleteRows,:subject,/SAT/)
		.transform('skip subgroups',DeleteRows,:breakdown, 'Homeless','Formerly English Learners','Migrant')
		.transform('delete n < 10',DeleteRows,:number_tested,'<10',nil)
		.transform('fill other columns',Fill,{
				year: 2017,
				entity_type: 'public_charter',
				test_data_type: 'm-step',
				test_data_type_id: 245,
				level_code: 'e,m,h',
				proficiency_band_id: 'null',
				proficiency_band: 'null'
		})
		.transform('map subject ids',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('map breakdown ids',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
		.transform('state ids and entity level',WithBlock,) do |row|
			if row[:school_id] == '     ' && row[:district_id] == '     '
				if row[:isdname] == 'Statewide'
					row[:entity_level] = 'state'
					row[:state_id] = 'state'
				elsif row[:isdname] != 'Statewide'
					row[:entity_level] = '*'
				end
			elsif row[:school_id] == '     '
				row[:entity_level] = 'district'
				row[:state_id] = row[:district_id].rjust(5,'0')
			else
				row[:entity_level] = 'school'
				row[:district_id] = row[:district_id].rjust(5,'0')
				row[:state_id] = row[:school_id].rjust(5,'0')
			end
			row
		end
		.transform('delete isd rows',DeleteRows,:entity_level,'*')
		.transform('change inequalities to negative',WithBlock) do |row|
			case row[:value_float]
			when '<5%'
				row[:value_float] = '-5'
			when '<10%'
				row[:value_float] = '-10'
			when '>90%'
				row[:value_float] = '-90'
			when '>95%'
				row[:value_float] = '-95'
		
			end
			row
		end
	end

	def config_hash
	{
		source_id: 9,
		state: 'mi',
		notes: 'DXT-2542 MI MSTEP 2017',
		url: 'http://www.michigan.gov/mde/',
		file: 'mi/2017/mi.2017.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter',
		source_name: 'MI DOE',
		date_valid: '2017-01-01 00:00:00'
	}
	end
end

MITestProcessor2017MSTEP.new(ARGV[0],max:nil,offset:nil).run
