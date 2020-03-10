require_relative "../test_processor"
GS::ETL::Logging.disable

class NYTestProcessor2016NYSARegentsRegentsCommonCore < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year = 2016
	end

	source('NY_Regents_2016.txt',[],col_sep: "\t") do |s|
		s.transform('test data type',Fill,{
			test_data_type: 'Regents',
			test_data_type_id: 31,
			grade: 'All'
		})
		.transform('remove all but 2016 data',DeleteRows,:year, '2014','2015')
		.transform('n tested < 10',DeleteRows,:tested, '1','2','3','4','5','6','7','8','9')
		.transform('remove rows where prof band is s',DeleteRows,:per_85100, 's')
		.transform('proficient & advanced',SumValues, :prof_null,:per_6584,:per_85100)
		.transform('remove wierd district groups',DeleteRows, :entity_cd,/^00000000000[1-9]{1}/)
	end
	source('NY_NYSA_2016.txt',[], col_sep: "\t") do |s|
		s.transform('extract grade',WithBlock,) do |row|
			row[:grade] = row[:item_desc].split(' ')[1]
			row
		end
		.transform('test data type',Fill,{
			test_data_type: 'NYSA',
			test_data_type_id: 30
		})
		.transform('n tested < 10',DeleteRows,:total_tested, '1','2','3','4','5','6','7','8','9')
		.transform('remove rows where prof band is --',DeleteRows,:l3l4_pct, '-')
		.transform('remove wierd district groups',DeleteRows, :bedscode,'1','2','3','4','5','6','7')
	end

	source('NY_RegentsCC_2016.txt',[],col_sep:"\t") do |s|
		s.transform('test data type',Fill,{
			test_data_type: 'Regents CC',
			test_data_type_id: 238,
			grade: 'All'
		})
		.transform('remove all but 2016 data',DeleteRows,:year, '2014','2015')
		.transform('n tested < 10',DeleteRows,:tested, '1','2','3','4','5','6','7','8','9')
		.transform('remove rows where prof band is s',DeleteRows,:per_level5, 's')
		.transform('proficient & advanced',SumValues, :prof_null,:per_level4,:per_level5)
		.transform('remove wierd district groups',DeleteRows, :entity_cd,/^00000000000[1-9]{1}/)
	end



	map_breakdown_ids = {
		'All Students' => 1,
		'American Indian or Alaska Native' => 4,
		'Asian or Native Hawaiian/Other Pacific Islander' => 22,
		'Black or African American' => 3,
		'Economically Disadvantaged' => 9,
		'English Language Learners' => 15,
		'Female' => 11,
		'General Education' => 14,
		'Hispanic or Latino' => 6,
		'Male' => 12,
		'Migrant' => 19,
		'Multiracial' => 21,
		'Non-English Language Learners' => 16,
		'Not Economically Disadvantaged' => 10,
		'Not Migrant' => 28,
		#Small Group Total
		'Students with Disabilities' => 13,
		'White' => 8,
		'Asian or Pacific Islander' => 22,
		'General Education Students' => 14,
		'Limited English Proficient' => 15,
		'Not Limited English Proficient' => 16
	}

	map_subject_ids = {
		'ELA' => 4,
		'Mathematics' => 5,
		'REG_COMALG1' => 7,
		'REG_COMENG' => 19,
		'REG_COMGEOM' => 9,
		'REG_COMALG2' => 11,
		'REG_ESCI_PS' => 43,#earth science
		'REG_INTALG' => 64,#integrated algebra
		'REG_ENG' => 19,
		'REG_LENV' => 29, #biology
		'REG_GLHIST' => 65, #global history and geography
		'REG_CHEM_PS' => 42, #chemistry
		'REG_PHYS_PS' => 41,#physics
		'REG_ALGTRIG' => 94, 
		'REG_USHG_RV' => 66,
		'REG_GEOM' => 9
	}

	map_prof_band_ids = {
		per_054: 34,
		per_5564: 35,
		per_6584: 36,
		per_85100: 37,
		l1_pct: 34,
		l2_pct: 35,
		l3_pct: 36,
		l4_pct: 37,
		l3l4_pct: 'null',
		per_level1: 115 ,
		per_level2: 116 ,
		per_level3: 117 ,
		per_level4: 118 ,
		per_level5: 119 ,
		prof_null: 'null'

	}

	shared do |s|
		s.transform('rename column headers',MultiFieldRenamer,{
			bedscode: :state_id,
			total_tested: :number_tested,
			subgroup_name: :breakdown,
			item_subject_area: :subject,
			#entity_name: :name,
			entity_cd: :state_id,
			tested: :number_tested,
			name: :entity_name
		})
		.transform('skip county rows', DeleteRows, :state_id, /000000$/)
		.transform('skip breakdown small group total', DeleteRows, :breakdown, 'Small Group Total')
		.transform('entity level',WithBlock,) do |row|
			if row[:state_id] == '0' || row[:state_id] == '111111111111'
				row[:entity_level] = 'state'
				row[:state_id] = 'state'
			elsif row[:state_id] =~ /0000$/
				row[:entity_level] = 'district'
				row[:district_name] = row[:entity_name]
				row[:district_id] = row[:state_id]
			else
				row[:entity_level] = 'school'
				row[:school_name] = row[:entity_name]
				row[:school_id] = row[:state_id]
			end
			if row[:entity_level] != 'state'
				#row[:state_id] = '%012d' %(row[:state_id])
				row[:state_id] = row[:state_id].to_s.rjust(12,'0')
			end
		#	require 'byebug'
		#	byebug
			row
		end
		.transform('transpose null prof band', Transposer, :proficiency_band, :value_float,:'per_054',:'per_5564',:'per_6584',:'per_85100',:prof_null,:l1_pct,:l2_pct,:l3_pct,:l4_pct,:'l3l4_pct',:per_level1, :per_level2,:per_level3,:per_level4,:per_level5)
		.transform('map prof band ids',HashLookup, :proficiency_band, map_prof_band_ids, to: :proficiency_band_id)
		.transform('map breakdown ids', HashLookup, :breakdown, map_breakdown_ids, to: :breakdown_id)
		.transform('map subject ids',HashLookup,:subject, map_subject_ids, to: :subject_id)
		.transform('fill other columns',Fill,{
			year: 2016,
			entity_type: 'public,charter',
			level_code: 'e,m,h'
		})
	end

	def config_hash
		{
			source_id: 16,
			state: 'ny',
			notes: 'DXT 1868 NY NYSA, Regents, Regents Common Core 2016',
			url: 'https://data.nysed.gov/downloads.php',
			file: 'ny/2016/DXT-1868/ny.2016.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

NYTestProcessor2016NYSARegentsRegentsCommonCore.new(ARGV[0], max:nil,offset:nil).run
