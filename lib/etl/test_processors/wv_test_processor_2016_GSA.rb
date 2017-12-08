require_relative "../test_processor"
GS::ETL::Logging.disable

class WVTestProcessor2016GSA < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year = 2016
	end

	map_subject_id = {
		'math' => 5,
		'm' => 5,
		'reading' => 2,
		'r' => 2,
		'science' => 25,
		's' => 25,
	}

	map_breakdown_id = {
		'Asian' => 2,
		'Black or African American' => 3,
		'Hispanic or Latino' => 6,
		'Multi-racial'=> 21,
		'Native American' => 4,#loaded as Native American or Native Alaskan
		'Pacific Islander' => 7,
		'White' => 8,
		'Female' => 11,
		'Male' => 12,
		'English Learner' => 15,
		'English Language Learner' => 15,
		'Low SES' => 9,
		'Special Education' => 13,
		'Total' => 1

	}

	source('WV_school_2016_GSA.txt',[],col_sep:"\t") do |s|
		s.transform('',Fill,{entity_level: 'school'})
		.transform('rename columns',MultiFieldRenamer,{
			school: :school_name,
			district: :district_name,
			school_id: :state_id,
			subgroup: :breakdown
		}) 	
		.transform('transpose subject and grades',Transposer,:grade_subject,:value_float,:'3m', :'4m', :'5m', :'6m', :'7m', :'8m', :'9m', :'10m', :'11m', :'3r', :'4r', :'5r', :'6r', :'7r', :'8r', :'9r', :'10r', :'11r', :'4s', :'6s', :'10s')
		.transform('remove empty rows',DeleteRows,:value_float,nil)
		.transform('',WithBlock,) do |row|
			row[:grade],row[:subject] = row[:grade_subject].to_s.partition(/\D/)
			#row[:grade] = row[:grade_subject].to_s.split(//)[1]	
			#require 'byebug'
			#byebug
			row[:value_float] = row[:value_float].gsub('%','')
			row[:state_id] = row[:state_id].rjust(5,'0')
			#require 'byebug'
			#byebug
			row
		end	
	end
	
	source('WV_district_2016_GSA.txt',[],col_sep:"\t") do |s|
		s.transform('',Fill,{entity_level: 'district'})
		.transform('rename columns',MultiFieldRenamer,{
			district: :district_name,
			subgroup: :breakdown,
			district_id: :state_id,
		}) 	
		.transform('',WithBlock,) do |row|
			#require 'byebug'
			#byebug
			row
		end
		.transform('transpose subject and grades',Transposer,:grade_subject,:value_float,:'3m', :'4m', :'5m', :'6m', :'7m', :'8m', :'9m', :'10m', :'11m', :'3r', :'4r', :'5r', :'6r', :'7r', :'8r', :'9r', :'10r', :'11r', :'4s', :'6s', :'10s')
		.transform('remove empty rows',DeleteRows,:value_float,nil)
		.transform('',WithBlock,) do |row|
			row[:grade],row[:subject] = row[:grade_subject].to_s.partition(/\D/)
			row[:district_id] = row[:state_id]
			#row[:grade] = row[:grade_subject].to_s.split(//)[1]	
			#require 'byebug'
			#byebug
			row[:value_float] = row[:value_float].gsub('%','')
			row[:state_id] = row[:state_id].rjust(2,'0').ljust(7,'0')
			#require 'byebug'
			#byebug
			row
		end
	end
	
	source('WV_state_2016_GSA.txt',[],col_sep:"\t") do |s|
		s.transform('',Fill,{entity_level: 'state'})
		.transform('rename columns',MultiFieldRenamer,{
			subgroup: :breakdown,
			percent: :value_float
		}) 	
		.transform('',WithBlock,) do |row|
			#row[:value_float] = row[:percent]
			#require 'byebug'
			#byebug	
			row[:value_float] = row[:value_float].gsub('%','')
			row
		end
		.transform('remove empty rows',DeleteRows,:value_float,nil)
	end

	shared do |s|
		s.transform('breakdown_id',HashLookup,:breakdown, map_breakdown_id,to: :breakdown_id)
		.transform('subject_id',HashLookup,:subject, map_subject_id,to: :subject_id)
		.transform('',Fill,{
			proficiency_band: 'prof_null',
			proficiency_band_id: 'null',
			year: 2016,
			entity_type: 'public,charter',
			level_code: 'e,m,h',
			test_data_type: 'WV GSA',
			test_data_type_id: 254
		})
	end
	

	def config_hash
		{
		source_id: 21,
		state: 'wv',
		notes: 'DXT-2141 WV GSA 2016',
		url: 'https://zoomwv.k12.wv.us/Dashboard/portalHome.jsp',
		file: 'wv/2016/DXT-2124/wv.2016.1.public.charter.[level].txt',
		level: nil,
		school_type: 'public,charter'
		}
	end

end

WVTestProcessor2016GSA.new(ARGV[0],max:nil,offset:nil).run
