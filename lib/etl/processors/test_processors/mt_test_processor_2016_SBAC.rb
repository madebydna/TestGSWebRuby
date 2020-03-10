require_relative "../test_processor"
GS::ETL::Logging.disable

class MTTestProcessor2016SBAC < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2016
	end

	map_breakdown = {
		'All Students' => 1,
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
		'Special Education Students' => 13,
		'White Students' => 8
	}

 source('mt_2016_math_state.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2016,
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
       at_or_above_proficient: :value_float,
       tested_students: :number_tested
     })
   .transform("removing %", WithBlock) do |row|
     row[:value_float] = row[:value_float].to_s.tr('%','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
 end

 source('mt_2016_ela_state.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2016,
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
       at_or_above_proficient: :value_float,
       tested_students: :number_tested
     })
   .transform("removing %", WithBlock) do |row|
     row[:value_float] = row[:value_float].to_s.tr('%','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
 end

 source('mt_2016_math_school.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2016,
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
       at_or_above_proficient: :value_float,
       tested_students: :number_tested,
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

  source('mt_2016_ela_school.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2016,
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
       at_or_above_proficient: :value_float,
       tested_students: :number_tested,
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
			notes:'DXT-2365 MT 2016 SBAC test load',
			url: '',
			file: 'mt/2016/mt.2016.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

MTTestProcessor2016SBAC.new(ARGV[0],max:nil,offset:nil).run
