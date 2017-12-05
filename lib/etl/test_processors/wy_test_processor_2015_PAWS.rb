require_relative "../test_processor"
GS::ETL::Logging.disable

class WYTestProcessor2015PAWS < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2015
	end

#	source('CharterSchool_WithIDS.txt',[],col_sep:"\t") do |s|
#		s.transform('fill entity level',Fill,{
#			entity_level: 'school',
#			breakdown: 'All Students',
#			})
#	end
	source('schools_withIDs.txt',[],col_sep:"\t") do |s|
		s.transform('fill entity level',Fill,{
			entity_level: 'school',
			})
	end
	source('PAWSPublicStateLevelSubGroups.txt',[],col_sep:"\t") do |s|
		s.transform('fill entity level',Fill,{
			entity_level: 'state',
			})
	end	
	source('districts_test_withIDs.txt',[],col_sep:"\t") do |s|
		s.transform('fill entity level',Fill,{
			entity_level: 'district',
			})
	end
	map_subject = {
		'Math' => 5,
		'Reading' => 2,
		'Science' => 25,
	}

	map_prof_band = {
		:percent_proficient_and_advanced => 'null'
	}

	map_breakdown = {
		'All Students' => 1,
		'Hispanic' => 6,
		'American Indian/Alaska Native' => 4,
		'Asian' => 2,
		'Black' => 3,
		'Native Hawaiian/Pacific Islander' => 112,
		'White' => 8,
		'Two or More Races' => 21,
		'Female' => 11,
		'Male' => 12,
		'English Language Learner' => 15,
		'Non-English Language Learner' => 16,
		'Free/Reduced Lunch' => 9,
		'Non-Free/Reduced Lunch' => 10,
		'Individual Education Plan (IEP)' => 13,
		#IEP on PAWS Alternate at Alt Standards	
		#IEP on PAWS Alternate at Grade Level Alt Standards
		#IEP on Standard Assessment with Accommodations 
		'Non-Individual Education Plan (non-IEP)' => 14,
		'Gifted/Talented' => 66,
		'Non-Gifted/Talented' => 120,
		'Migrant' => 19,
		'Non-Migrant' => 28,
		'Homeless' => 95,
		'Non-Homeless' => 121

	}

	shared do |s|
		s.transform('rename columns',MultiFieldRenamer,
		 {
		number_of_students_tested: :number_tested,
		subgroup: :breakdown
		})
		.transform('number tested',WithBlock,) do |row|
			row[:number_tested] = row[:number_tested].split('-').first
			row[:number_tested] = row[:number_tested].strip
			row
		end
		.transform('state id',WithBlock,) do |row|
			if row[:entity_level] == 'district'
				row[:state_id] = row[:district_id]
			elsif row[:entity_level] == 'school'
				row[:state_id] = row[:school_id]
			end
			row
		end
		.transform('skip number tested',DeleteRows, :number_tested, '0','1','6',nil)
		.transform('skip iep rows',DeleteRows, :breakdown, /^IEP on/)
		.transform('ski academic year rows',DeleteRows, :breakdown, /Full Academic Year/)
		.transform('prof bands',Transposer,:proficiency_band, :value_float, :percent_proficient_and_advanced)
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row
		end
		.transform('remove %',WithBlock,) do |row|
			unless row[:value_float].nil?
			       row[:value_float] = row[:value_float].tr('%','')
			end
			if row[:value_float].nil?
				row[:value_float] = 'skip'
			end
			row
		end
		.transform('remove rows with >80%, <20%',DeleteRows,:value_float, '>= 80','<= 20','skip')
		.transform('change inequalities',WithBlock,) do |row|
			case row[:value_float] 
			when '>= 95'
				row[:value_float] = '-95'
			when '<=  5'
				row[:value_float] = '-5'
			when '>= 90'
				row[:value_float] = '-90'
			when '<= 10'
				row[:value_float] = '-10'
			end
			row
		end
		.transform('map subject id',HashLookup, :subject, map_subject, to: :subject_id)
		.transform('map breakdown id',HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
		.transform('map prof band id',HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
		.transform('Fill other columns',Fill,{
		year: 2015,
		entity_type: 'public_charter',
		test_data_type_id: 114,
		test_data_type: 'PAWS',
		level_code: 'e,m,h'
		})
	end

	def config_hash
		{
			source_id:49,
			state:'wy',
			notes:'DXT-1636 WY 2015 PAWS test load',
			url: 'http://fusion.edu.wyoming.gov/',
			file: 'wy/2015/wy.2015.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public_charter'
		}
	end
end

WYTestProcessor2015PAWS.new(ARGV[0],max:nil,offset:nil).run
