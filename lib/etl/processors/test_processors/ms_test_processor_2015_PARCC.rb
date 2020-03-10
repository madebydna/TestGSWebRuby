require_relative "../test_processor"
GS::ETL::Logging.disable

class MSTestProcessor2015PARCC < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2015
	end

	source('PARCC_2015_G3ELA_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G4ELA_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G5ELA_out.txt',[],col_sep:"\t")	
	source('PARCC_2015_G6ELA_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G7ELA_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G8ELA_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G3MATH_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G4MATH_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G5MATH_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G6MATH_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G7MATH_out.txt',[],col_sep:"\t")
	source('PARCC_2015_G8MATH_out.txt',[],col_sep:"\t")
	source('PARCC_2015_Alg1_out.txt',[],col_sep:"\t")
	source('PARCC_2015_Eng2_out.txt',[],col_sep:"\t")

	map_subject = {
		'MATH' => 5,
		'ELA' => 4,
		'Algebra 1' => 7,
		'English2' => 27,
	}

	map_prof_band = {
		level1x: 115,
	        level2x: 116,
		level3x: 117,
		level4x: 118,
		level5x: 119,	
		level4_5: 'null'
	}

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,
		 {
		gradex: :grade,
		name: :school_name,
	        entity_typex: :entity_level,
		number_testedx: :number_tested,
		subjectx: :subject,
		})
		.transform('null prof band',SumValues,:level4_5, :level4x,:level5x)
		.transform('prof bands',Transposer,:proficiency_band, :value_float, :'level1x',:'level2x',:'level3x',:'level4x',:'level5x',:level4_5)
		.transform('remove %',WithBlock,) do |row|
			unless row[:value_float].nil?
			       row[:value_float] = (row[:value_float].to_s).tr('%','')
			       row[:value_float] = (row[:value_float].to_f).round(2)
			end
			row
		end
		.transform('state_id length',WithBlock,) do |row|
			if row[:entity_level] == 'district'
				row[:state_id] = '%04s' % (row[:state_id].to_s)
			elsif row[:entity_level] == 'school'
				row[:state_id] = '%07s' % (row[:state_id].to_s)
			elsif row[:entity_level] == 'state'
				row[:state_id] = 'state'
			end
			row
		end
		.transform('remove rows without id',DeleteRows,:state_id, /NA/)
		.transform('remove rows with no data',DeleteRows,:number_tested, '*')
		.transform('remove school ne madison - no state id',DeleteRows,:school_name, /ne madison/)
		.transform('map subject id',HashLookup, :subject, map_subject, to: :subject_id)
		.transform('map prof band id',HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row
		end
		.transform('Fill other columns',Fill,{
		year: 2015,
		entity_type: 'public_charter',
		test_data_type_id: 314,
		test_data_type: 'PARCC',
		level_code: 'e,m,h',
		breakdown: 'All',
		breakdown_id: 1
		})
	end

	def config_hash
		{
			source_id:30,
			state:'ms',
			notes:'DXT-1670 MS 2015 PARCC test load',
			url: 'http://www.mde.k12.ms.us',
			file: 'ms/2015/ms.2015.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public_charter'
		}
	end
end

MSTestProcessor2015PARCC.new(ARGV[0],max:nil,offset:nil).run
