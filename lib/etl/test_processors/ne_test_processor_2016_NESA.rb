require_relative '../test_processor'
GS::ETL::Logging.disable

class  NETestProcessor2016NESA < GS::ETL::TestProcessor

	def initialize(*arts)
		super
		@year = 2016
	end

	map_subject_id = {
	'Mathematics' => 5,
	'Writing' => 3,
	'Science' => 25,
	'Reading' =>  2
	}

	map_breakdown_id = {
	'All students' => 1,
	'Male' => 12,
	'Female' => 11,
	'Students eligible for free and reduced lunch' => 9,
	'Special Education Students' => 13,
	'English Language Learners' => 15,
	'Hispanic' => 6,
	'American Indian/Alaska Native' => 4,
	'Asian' => 2,
	'Black or African American' => 3,
	'Native Hawaiian or Other Pacific Islander' => 112,
	'White' => 8,
	'Two or More Races' => 21
	}

	#source('NEValuesOver100.txt',[],col_sep:"\t")
	source('NeSA_Math_Proficient_20152016.txt',[],col_sep:',')
	source('NeSA_Writing_Proficient_20152016.txt',[],col_sep:',')
	source('NeSA_Reading_Proficient_20152016.txt',[],col_sep:',')
	source('NeSA_Science_Proficient_20152016.txt',[],col_sep:',')
	
	shared do |s|
		s.transform('delete rows from previous years',DeleteRows,:school_year, '2012-2013','2013-2014','2014-2015')
		.transform('remove rows where type = LC',DeleteRows,:type,'LC')
		.transform('remove rows where subgroup is',DeleteRows,:student_subgroup,'Students served in migrant programs','Highly Mobile Students','Special Education Students - Alternate Assessment')
		.transform('entity type and state_ids and names',WithBlock,) do |row|
			if row[:type] == 'ST'
				row[:entity_level] = 'state'
				row[:state_id] = 'state'
			elsif row[:type] == 'DI'
				row[:entity_level] = 'district'
				row[:district_name] = row[:agency_name]
				row[:state_id] =  row[:county].rjust(2,'0')+row[:district].rjust(4,'0') + '000'
			elsif row[:type] == 'SC'
				row[:entity_level] = 'school'
				row[:school_name] = row[:agency_name]
				row[:state_id] = row[:county].rjust(2,'0')+row[:district].rjust(4,'0')+row[:school].rjust(3,'0')
			end
			row
		end
		.transform('calculate prof & above',WithBlock,) do |row|
			row[:basic_pct] = row[:basic_pct].to_f
			row[:proficient_pct] = row[:proficient_pct].to_f
			row[:advanced_pct] = row[:advanced_pct].to_f
			#require 'byebug'
			#byebug
			#advanced is -1
			if row[:basic_pct] != -1 && row[:proficient_pct] != -1  && row[:advanced_pct] == -1
				row[:advanced_pct] = 1.00 - (row[:basic_pct]+ row[:proficient_pct])
				if row[:advanced_pct] < 0
					row[:advanced_pct] = 0
				end
				row[:value_float] = row[:proficient_pct] + row[:advanced_pct]
			#proficient is -1
			elsif row[:basic_pct] != -1 && row[:proficient_pct] == -1  && row[:advanceda_pct] != -1
				row[:proficient_pct] = 1.00 - (row[:basic_pct]+ row[:advanced_pct])
				row[:value_float] = row[:proficient_pct] + row[:advanced_pct]
			else
				row[:value_float] = row[:proficient_pct] + row[:advanced_pct]
				#if row[:value_float] == 1.01
				#	row[:value_float] = 1.00
				#end
			end
			#proficient and advanced are -1
			if row[:proficient_pct] == -1 && row[:advanced_pct] == -1 && row[:basic] != -1
				row[:value_float] = 1.00 - row[:basic_pct]
			end
			if row[:value_float] > 1.01 || row[:value_float] < 0
				row[:value_float] = '*'
			end
			row
		end
		.transform('delete rows where value_float = *',DeleteRows,:value_float,'*')
		.transform('Rename columns',MultiFieldRenamer,{
			student_subgroup: :breakdown,
			school: :school_id,
			district: :district_id
		})
		.transform('map subject id',HashLookup,:subject,map_subject_id,to: :subject_id)
		.transform('map breakdown id',HashLookup,:breakdown,map_breakdown_id,to: :breakdown_id)
		.transform('fill in other rows',Fill,{
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			year: 2016,
			test_data_type: 'NESA',
		        test_data_type_id: 185,
			proficiency_band: 'null',
			proficiency_band_id: 'null'	
		})
		.transform('',WithBlock,) do |row|
			row[:value_float] = (row[:value_float] * 100).round(4)
			row[:grade] = row[:grade].to_s.sub(/^[ 0]+/,'')	
			#require 'byebug'
			#byebug
		row	
		end
	end


	def config_hash
	{
	source_id: 50,
	state: 'ne',
	notes: 'DXT-2153 NE NESA 2016',
	url: 'http://nep.education.ne.gov/Links',
	file: 'ne/2016/ne.2016.1.public.charter.[level].txt',
	level: nil,
	school_type: 'public,charter'
	}
	end

end

NETestProcessor2016NESA.new(ARGV[0],offset:nil,max:nil).run
