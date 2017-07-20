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
		xofstudentslevel1: 115,
		xofstudentslevel2: 116,
		xofstudentslevel3: 117,
		xofstudentslevel4: 118,
		xofstudentslevel5: 119,
		xofstudentslevel3andabove: 'null'
	}

	source('fsa_2016.txt',[],col_sep:"\t")

	shared do |s|
		s.transform('Rename column headers',MultiFieldRenamer,{
		gradelevel: :grade,
		xofstudents: :number_tested,
		})
		.transform('entity_level',WithBlock,) do |row|
			if row[:school] == 'district'
				row[:entity_level] = 'district'
			elsif row[:district] == 'state' && row[:school] == 'state'
				row[:entity_level] = 'state'
			elsif row[:school] != 'state' && row[:school] != 'district'
				row[:entity_level] = 'school'
			end
			#require 'byebug'
			#byebug
			row
		end
		.transform('extract district id and name, school id and name',WithBlock,) do |row|
			if row[:entity_level] != 'state'
				row[:district_id] = row[:district].split('-').first
				row[:school_id] = row[:school].split('-').last
				row[:district_name] = row[:district].split('-').last
				row[:school_name] = row[:school].split('-').first
			end
			row
			#require 'byebug'
			#byebug
		end
		.transform('state id',WithBlock,) do |row|
			if row[:entity_level] == 'school'
				row[:state_id] = "%02s%04s" % [row[:district_id],row[:school_id]]
			elsif row[:entity_level] == 'district'
				row[:state_id] = "%02s" % [row[:district_id]]
			else
				row[:state_id] = 'state'
			end
			row
		end
		.transform('grade',WithBlock,) do |row|
			if row[:grade] =~ /EOC/
				row[:grade] = 'All'
			else
				row[:grade] = row[:grade].split('-').first
				if row[:grade] != '10'
					row[:grade] = row[:grade].sub!(/^0+/,"")
				end
			end
			row
		end
		.transform('test data type',WithBlock,) do |row|
			if row[:subject] =~ /Civics|US History|Biology/
				row[:test_data_type] = 'EOC'
				row[:test_data_type_id] = 163
			else
				row[:test_data_type] = 'FSA'
				row[:test_data_type_id] = 302
			end
			row
		end
		.transform('set prof null column to **.* so it is deleted to remove by grade data for Alg1,Alg2,Geom',WithBlock,) do |row|
			if row[:subject] =~ /Algebra|Geometry/  && row[:grade] != 'All'
				row[:xofstudentslevel3andabove] = '**.*'
			end
			row
		end
		.transform('remove rows with breakdown not reported',DeleteRows, :breakdown, 'Not Reported')
		.transform('remove rows with no data',DeleteRows,:xofstudentslevel3andabove, '**.*','NA')
		.transform('transpose prof bands',Transposer,:proficiency_band, :value_float, :xofstudentslevel1,:xofstudentslevel2,:xofstudentslevel3,:xofstudentslevel4,:xofstudentslevel5,:xofstudentslevel3andabove)
		.transform('map prof bands',HashLookup,:proficiency_band, map_prof_band_id, to: :proficiency_band_id)
		.transform('map subject id',HashLookup,:subject, map_subject_id, to: :subject_id)
		.transform('map breakdown id',HashLookup,:breakdown, map_breakdown_id, to: :breakdown_id)
		.transform('Fill in remaining columns',Fill,{
		entity_type: 'public,charter',
		level_code: 'e,m,h',
		year: '2016'
		})
	end

	def config_hash
		{
		source_id: 1,
		state: 'fl',
		notes: 'DXT-1841 FL FSA, EOC 2016',
		url: 'http://www.fldoe.org/accountability/assessments/k-12-student-assessment/results/2016.stml',
		file: 'fl/2016/fl.2016.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

FLTestProcessor2016FSA_EOC.new(ARGV[0],max:nil,offset:nil).run
