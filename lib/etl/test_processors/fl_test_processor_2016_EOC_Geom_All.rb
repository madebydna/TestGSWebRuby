require_relative "../test_processor"
GS::ETL::Logging.disable

class FLTestProcessor2016FSA_EOC < GS::ETL::TestProcessor
	
	def initialize(*args)
		super
		@year = 2016
	end
	
	map_subject_id = {
	'ELA' => 4,
	'Math'=> 5,
	'Algebra 1' => 7,
	'Algebra 2' => 11,
	'Geometry' => 9,
	'Biology' => 29,
	'Civics' => 83,
	'US History' => 30
	}

	map_breakdown_id = {
	'ELL' => 15,
	'Non-ELL' => 16,
	'Eco. Disadvantaged' => 9,
	'Non-Eco. Disadvantaged' => 10,
	'Female' => 11,
	'Male' => 12,
	'1-White' => 8,
	'2-Hispanic' => 6,
	'3-Black' => 3,
	'4-Two or More Races' => 21,
	'5-Asian' => 2,
	'6-American Indian' => 4,
	'7-Pacific Islander' => 7,
	'All' => 1,
	'Disabled' => 13,
	'Non-Disabled' => 14 
	}

	map_prof_band_id = {
		level_1: 115,
		level_2: 116,
		level_3: 117,
		level_4: 118,
		level_5: 119,
		prof_null: 'null'
	}

	source('FL_EOC_Geom_2016_Overall.txt',[],col_sep:"\t")

	shared do |s|
		s.transform('rename headers',MultiFieldRenamer, {subgroup: :breakdown})
		.transform('sum null prof band',WithBlock,) do |row|
			row[:prof_null] = ( row[:level_3].to_f. + row[:level_4].to_f + row[:level_5].to_f ).round(2)
			row
		end
		.transform('transpose prof bands',Transposer,:proficiency_band, :value_float, :level_1,:level_2,:level_3,:level_4,:level_5,:prof_null)
		.transform('map prof bands',HashLookup,:proficiency_band, map_prof_band_id, to: :proficiency_band_id)
		.transform('subject',Fill,{subject: 'Geometry'})
		.transform('map subject id',HashLookup,:subject, map_subject_id, to: :subject_id)
		.transform('map breakdown id',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
		.transform('Fill in remaining columns',Fill,{
		entity_type: 'public,charter',
		entity_level: 'state',
		test_data_type: 'FSA',
		test_data_type_id: '302',
		grade: 'All',
		level_code: 'e,m,h',
		year: '2016'
		})
	end

	def config_hash
		{
		source_id: 1,
		state: 'fl',
		notes: 'DXT-1960 FL GEOM EOC Overall 2016',
		url: 'http://www.fldoe.org/accountability/assessments/k-12-student-assessment/results/2016.stml',
		file: 'fl/2016/DXT-1960/fl.2016.2.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

FLTestProcessor2016FSA_EOC.new(ARGV[0],max:nil,offset:nil).run
