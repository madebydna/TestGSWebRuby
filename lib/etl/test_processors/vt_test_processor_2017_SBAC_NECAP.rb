require_relative "../test_processor"

class VTTestProcessor2017SBAC_NECAP < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2017
	end

	map_breakdown_gsdata_id = {
		'All Students' => 1,
		'No Special Ed' => 30,
		'Not ELL' => 33,
		'Not FRL' => 24,
		'Female' => 26,
		'American Indian or Alaskan Native' => 18,
		'Special Ed' => 27,
		'ELL' => 32,
		'FRL' => 23,
		'Male' => 25,
		'Asian' => 16,
		'Black' => 17,
		'Hispanic' => 19,
		'Native Hawaiian or Pacific Islander' => 20,
		'White' => 21
	}


	map_academic_gsdata_id = {
		'SB English Language Arts ' => 4,
		'SB Math ' => 5,
		'NECAP Science ' => 19
	}
	
	map_prof_band_id = { #these bands are mapped to the wrong ids, fixed in a script after
		level_4_proficient_with_distinction: 8, 
		level_3_proficient: 7, 
		level_2_partially_proficient: 6, 
		level_1_substantially_below_proficient: 5,
		proficient_and_above: 1
	}

	source('VT_2017_NECAP_SCHOOL.txt',[],col_sep:"\t") do |s|
		s.transform("Renaming fields", MultiFieldRenamer,
    	{
      		leaid: :district_id,
      		leaname: :district_name,
      		n: :number_tested,
			group: :breakdown
  		})
		.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
		.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
		.transform('',WithBlock,) do |row|
			unless row[:disaggregate] == 'Disability' && row[:breakdown] == 'All Students'
				row
			end
		end
		.transform('prof and above',SumValues,:proficient_and_above,:level_4_proficient_with_distinction,:level_3_proficient)
		.transform('transpose prof bands',Transposer,:proficiency_band,:value_float,:proficient_and_above,:level_4_proficient_with_distinction,:level_3_proficient,:level_2_partially_proficient,:level_1_substantially_below_proficient)
		.transform('map prof band id',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_gsdata_id)		
		.transform('entity level',Fill,{
			entity_level: 'school',
			test_data_type: 'necap',
			gsdata_test_data_type_id: 191,
			})
	end

	source('VT_2017_SBAC_PUBLIC_SCHOOL.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
			total_proficient_and_above: :value_float,
			lea_id: :district_id,
			lea_name: :district_name,
			n: :number_tested,
			group: :breakdown
		})
		.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
		.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
		.transform('entity level',Fill,{
			entity_level: 'school',
			test_data_type: 'sbac',
			gsdata_test_data_type_id: 218,
			proficiency_band: 'proficient_and_above',
			proficiency_band_gsdata_id: 1
			})
	end

	source('VT_2017_SBAC_INDEP_SCHOOL.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
			total_proficient_and_above: :value_float,
			n: :number_tested,
			group: :breakdown
		})
		.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
		.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
		.transform('entity level',Fill,{
			entity_level: 'school',
			test_data_type: 'sbac',
			gsdata_test_data_type_id: 218,
			proficiency_band: 'proficient_and_above',
			proficiency_band_gsdata_id: 1
			})
	end

	source('VT_2017_SBAC_STATE.txt',[],col_sep:"\t") do |s|
		s.transform('rename fields',MultiFieldRenamer,{
			total_proficient_and_above: :value_float,
			n: :number_tested,
			group: :breakdown
		})
		.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
		.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
		.transform('entity level',Fill,{
			entity_level: 'state',
			test_data_type: 'sbac',
			gsdata_test_data_type_id: 218,
			proficiency_band: 'proficient_and_above',
			proficiency_band_gsdata_id: 1,
			})
	end

	source('VT_2017_NECAP_STATE.txt',[],col_sep:"\t") do |s|
		s.transform('',MultiFieldRenamer,{
			n: :number_tested,
			group: :breakdown
		})
		.transform('remove rows with blank or 0 ntested',DeleteRows,:number_tested,nil,'0')
		.transform('remove migrant and not migrant',DeleteRows,:breakdown,'Migrant','Not Migrant')
		.transform('',WithBlock,) do |row|
			unless row[:disaggregate] == 'Disability' && row[:breakdown] == 'All Students'
				row
			end
		end
		.transform('prof and above',SumValues,:proficient_and_above,:level_4_proficient_with_distinction,:level_3_proficient)
		.transform('transpose prof bands',Transposer,:proficiency_band,:value_float,:proficient_and_above,:level_4_proficient_with_distinction,:level_3_proficient,:level_2_partially_proficient,:level_1_substantially_below_proficient)
		.transform('map prof band id',HashLookup,:proficiency_band, map_prof_band_id,to: :proficiency_band_gsdata_id)		
		.transform('entity level',Fill,{
			entity_level: 'state',
			test_data_type: 'necap',
			gsdata_test_data_type_id: 191,
			})
	end



	shared do |s|
		s.transform('',Fill,{
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			year: 2017
		})
		.transform('subject and grade',WithBlock,) do |row|
			row[:subject],row[:grade] = row[:test_name].split('Grade')
			row
		end
		.transform('Remove 0 from grade and '%' from value_float',WithBlock,) do |row|
			row[:value_float] = row[:value_float].to_s.gsub('%','')
			row[:grade] = row[:grade].to_s.sub(/^[ 0]+/,'')
			row
		end
		.transform('breakdowns',HashLookup,:breakdown,map_breakdown_gsdata_id,to: :breakdown_gsdata_id)
		.transform('subject',HashLookup,:subject, map_academic_gsdata_id, to: :academic_gsdata_id)
        .transform("Filling in description", WithBlock) do |row|
             if row[:gsdata_test_data_type_id] == 218
                row[:description] = 'In 2016-2017, students in Vermont took The Smarter Balanced assessment, which replaced Vermont\'s previous assessment, the NECAP, in 2016. The new assessment of English Language Arts and Mathematics asks students to demonstrate and apply their knowledge and skills in areas such as critical thinking, analytical writing, and problem solving. The Smarter Balanced assessment is aligned with the Common Core State Standards, uses state of the art computer adaptive testing and accessibility technologies, and provides a continuum of summative, interim and formative tools that can be used for a variety of educational purposes.'
                row[:notes] = 'DXT-3080: VT VT SBAC'
             elsif row[:gsdata_test_data_type_id] == 191
                row[:description] = 'In 2016-2017, students in Vermont took the science assessment, which is part of the New England Common Assessment Program (NECAP). It is designed to measure students\' scientific literacy and inquiry. The NECAP science assessment, which combines scores from multiple choice and short answer questions with results from an inquiry task that requires students to analyze and interpret findings from an actual science experiment.'
                row[:notes] = 'DXT-3080: VT NECAP'
             end
         row
        end
        .transform("Creating StateID, district and school id and dist and sch names", WithBlock) do |row|
     		 if row[:entity_level] == 'state'
       			row[:state_id] = 'state'
     		elsif row[:entity_level] == 'school'
        		row[:state_id] = row[:psid]
        		row[:school_id] = row[:psid]
            end
            row
        end
	end

	def config_hash
		{
		gsdata_source_id: 50,
		source_name: 'Vermont Agency of Education',
		state: 'vt',
        date_valid: '2017-01-01 00:00:00',
		notes: 'DXT-3080 VT SBAC, NECAP 2017',
		url: 'https://education.vermont.gov/documents/data-smarter-balanced-state-school-level-2017',
		file: 'vt/2017/vt.2017.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

VTTestProcessor2017SBAC_NECAP.new(ARGV[0],max:nil,offset:nil).run
