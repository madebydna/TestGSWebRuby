require_relative "../test_processor"
GS::ETL::Logging.disable

class MTTestProcessor2017SBAC < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2017
	end

	map_breakdown = {
		'All Students' => 1,
    'ALL STUDENTS' => 1,
		'Asian Students' => 2,
		'Black or African-American Students' => 3,
		'Female Students' => 11,
		'Economically Disadvantaged Students' => 9,
    'Economically Disadvantaged' => 9,
		'Hispanic/Latino Students' => 6,
    'Hispanic/ Latino Students' => 6,
		'English Learner Students' => 15,
		'Male Students' => 12,
		'American Indian/Alaska Native Students' => 4,
    'American Indian/ Alaska Native Students' => 4,
		'Native Hawaiian or Other Pacific Island Students' =>112,
    'Native Hawaiian or Other Pacific Island Student' =>112,
		'Special Education Students' => 13,
		'White Students' => 8
	}

 source('mt_2017_math_state.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       entity_level: 'state',
       proficiency_band: 'null',
       proficiency_band_id: 'null',
       subject: 'math',
       subject_id: 5,
       test_data_type: 'MT SBAC',
       test_data_type_id: 328
     })
   .transform("",MultiFieldRenamer,
     {
       grade: :grade,
       group: :breakdown,
       _proficient: :value_float,
       tested_enrollment_count: :number_tested
     })
   .transform("removing %", WithBlock) do |row|
     row[:value_float] = row[:value_float].to_s.tr('%','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
 end

 source('mt_2017_ela_state.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       entity_level: 'state',
       proficiency_band: 'null',
       proficiency_band_id: 'null',
       subject: 'ela',
       subject_id: 4,
       test_data_type: 'MT SBAC',
       test_data_type_id: 328
     })
   .transform("",MultiFieldRenamer,
     {
       grade: :grade,
       group: :breakdown,
       _proficient: :value_float,
       tested_enrollment_count: :number_tested
     })
   .transform("removing %", WithBlock) do |row|
     row[:value_float] = row[:value_float].to_s.tr('%','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
 end

 source('mt_2017_math_school.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       entity_level: 'school',
       proficiency_band: 'null',
       proficiency_band_id: 'null',
       subject: 'math',
       subject_id: 5,
       test_data_type: 'MT SBAC',
       test_data_type_id: 328
     })
   .transform("",MultiFieldRenamer,
     {
       grade: :grade,
       group: :breakdown,
       _proficient: :value_float,
       tested_student_count: :number_tested,
       schname: :school_name
     })
   .transform("removing %", WithBlock) do |row|
     row[:value_float] = row[:value_float].to_s.tr('%','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
   .transform('deleting suppressed rows',DeleteRows,:number_tested,'*','6','7','8','9')
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%04i' % (row[:schcode].to_i)
     row
   end
 end

  source('mt_2017_ela_school.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       entity_level: 'school',
       proficiency_band: 'null',
       proficiency_band_id: 'null',
       subject: 'ela',
       subject_id: 4,
       test_data_type: 'MT SBAC',
       test_data_type_id: 328
     })
   .transform("",MultiFieldRenamer,
     {
       grade: :grade,
       group: :breakdown,
       _proficient: :value_float,
       tested_student_count: :number_tested,
       schname: :school_name
     })
   .transform("removing %", WithBlock) do |row|
     row[:value_float] = row[:value_float].to_s.tr('%','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
   .transform('deleting suppressed rows',DeleteRows,:number_tested,'*','6','7','8','9')
   .transform("padding ids",WithBlock) do |row|
     row[:state_id] = '%04i' % (row[:schcode].to_i)
     row
   end
 end


	def config_hash
		{
			source_id:43,
			state:'mt',
			notes:'DXT-2365 MT 2017 SBAC test load',
			url: '',
			file: 'mt/2017/mt.2017.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

MTTestProcessor2017SBAC.new(ARGV[0],max:nil,offset:nil).run
