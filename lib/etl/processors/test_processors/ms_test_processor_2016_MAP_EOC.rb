require_relative "../test_processor"
GS::ETL::Logging.disable

class MSTestProcessor2016MAPEOC < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2016
	end

	map_subject = {
		'math' => 5,
		'ela' => 4,
		'algebrai' => 7,
		'englishii' => 27,
		'Math' => 5,
		'Alg1' => 7,
		'ELA' => 4,
		'English II' => 27
	}

	map_prof_band = {
		'1' => 115,
		'2' => 116,
		'3'=> 117,
		'4' => 118,
		'5' => 119,
		'45' => 'null',
		level_1: 115,
		level_2: 116,
		level_3: 117,
		level_4: 118,
		level_5: 119,
		Val: 'null'
	}

	map_breakdown = {
		'All Students' => 1,
		'Asian' => 2,
		'Black' => 3,
		'English Proficient' => 16,
		'Female' => 11,
		'Free/Reduced Eligible' => 9,
		'Hispanic' => 6,
		'Limited English Proficient' => 15,
		'Male' => 12,
		'Native American' => 4,
		'Not Free/Reduced Eligible' => 10,
		'Pacific Islander' =>7,
		'Students w/Disabilities' => 13,
		'Students w/out Disabilities' => 14,
		'Two or More' => 21,
		'White' => 8
	}

 source('ms_state_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       entity_level: 'state',
       number_tested: 'null',
       breakdown: 'All Students',
       breakdown_id: 1
     })
   .transform('null prof band',SumValues,:Val, :level_4,:level_5)
   .transform("transposing proficiency bands", Transposer, :proficiency_band, :value_float, :level_1, :level_2, :level_3, :level_4, :level_5, :Val)
   .transform("mapping subjects",
     HashLookup, :subject, map_subject, to: :subject_id)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
   .transform("adding test type", WithBlock) do |row|
     if row[:subject] == 'Math'
       row[:test_data_type] = 'MAP'
       row[:test_data_type_id] = 323
       row
     elsif row[:subject] == 'ELA'
       row[:test_data_type] = 'MAP'
       row[:test_data_type_id] = 323
       row
     elsif row[:subject] == 'Alg1'
       row[:test_data_type] = 'MAP EOC'
       row[:test_data_type_id] = 324
       row
     elsif row[:subject] == 'English II'
       row[:test_data_type] = 'MAP EOC'
       row[:test_data_type_id] = 324
       row
     end
   end
   .transform("removing %", WithBlock) do |row|
     row[:value_float] = row[:value_float].to_s.tr('%','')
     row
   end
 end

 source('ms_ela_math_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("",MultiFieldRenamer,
     {
       grade: :grade,
       subgroup: :breakdown,
       school_name: :school_name,
       district_name: :district_name,
       district_id: :district_id
     })
   .transform("Removing zeros from grade", WithBlock) do |row|
     row[:grade] = row[:grade].tr('0','')
     row
   end
   .transform("padding ids",WithBlock) do |row|
     row[:district_id] = '%04i' % (row[:district_id].to_i)
     row[:school_id] = '%03i' % (row[:school_id].to_i)
     row
   end
   .transform("state id", WithBlock) do |row|
     row[:state_id] = row[:district_id]+row[:school_id]
     row[:school_id] = row[:district_id]+row[:school_id]
     row
   end
   .transform('Fill other columns',Fill,{
     year: 2016,
     entity_type: 'public_charter',
     level_code: 'e,m,h',
     entity_level: 'school',
     number_tested: 'null',
     test_data_type: 'MAP',
     test_data_type_id: 323
   })
   .transform("target nil values",WithBlock) do |row|
     if row[:math_4].nil? & row[:math_5].nil?
        row[:math_4] = 9999
     end
     row
   end
   .transform("target nil values",WithBlock) do |row|
     if row[:ela_4].nil? & row[:ela_5].nil?
       row[:ela_4] = 9999
     end
     row
   end
   .transform('null prof band',SumValues,:math_45, :math_4,:math_5)
   .transform('null prof band',SumValues,:ela_45, :ela_4,:ela_5)
   .transform("transposing proficiency bands", Transposer, :subject, :value_float, :math_1, :ela_1, :math_2, :ela_2, :math_3, :ela_3, :math_4, :ela_4, :math_5, :ela_5, :math_45, :ela_45)
   .transform('remove %',WithBlock,) do |row|
     unless row[:value_float].nil?
            row[:value_float] = row[:value_float].to_s.tr('%','')
            row[:value_float] = row[:value_float].to_f
     end
     if row[:value_float].nil?
        row[:value_float] = 'skip'
     end
     row
   end
   .transform("",WithBlock) do |row|
     row[:proficiency_band] = row[:subject]
     row
   end
   .transform('remove blank value rows', DeleteRows, :value_float,'skip',9999)
   .transform("splicing the subject values",WithBlock) do |row|
     row[:subject] = row[:subject].to_s.gsub!(/[0-9]/,'').gsub!('_','')
     row
   end
   .transform("splicing the proficiency band values",WithBlock) do |row|
     row[:proficiency_band] = row[:proficiency_band].to_s.gsub!(/[a-z]/,'').gsub!('_','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
   .transform("mapping subjects",
     HashLookup, :subject, map_subject, to: :subject_id)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
 end


 source('test.txt',[],col_sep:"\t") do |s|
   s.transform("",MultiFieldRenamer,
     {
       subgroup: :breakdown,
       school_name: :school_name,
       district_name: :district_name,
       district_id: :district_id
     })
   .transform("padding ids",WithBlock) do |row|
     row[:district_id] = '%04i' % (row[:district_id].to_i)
     row[:school_id] = '%03i' % (row[:school_id].to_i)
     row
   end
   .transform("state id", WithBlock) do |row|
     row[:state_id] = row[:district_id]+row[:school_id]
     row[:school_id] = row[:district_id]+row[:school_id]
     row
   end
   .transform('Fill other columns',Fill,{
     year: 2016,
     entity_type: 'public_charter',
     level_code: 'e,m,h',
     entity_level: 'school',
     number_tested: 'null',
     grade: 'All',
     test_data_type: 'MAP EOC',
     test_data_type_id: 324
   })
   .transform("target nil values",WithBlock) do |row|
     if row[:algebra_i_4].nil? & row[:algebra_i_5].nil?
        row[:algebra_i_4] = 9999
     end
     row
   end
   .transform("target nil values",WithBlock) do |row|
     if row[:english_ii_4].nil? & row[:english_ii_5].nil?
       row[:english_ii_4] = 9999
     end
     row
   end
   .transform('null prof band',SumValues,:algebra_i_45, :algebra_i_4,:algebra_i_5)
   .transform('null prof band',SumValues,:english_ii_45, :english_ii_4,:english_ii_5)
   .transform("transposing proficiency bands", Transposer, :subject, :value_float, :algebra_i_1, :english_ii_1, :algebra_i_2, :english_ii_2, :algebra_i_3, :english_ii_3, :algebra_i_4, :english_ii_4, :algebra_i_5, :english_ii_5, :algebra_i_45, :english_ii_45)
   .transform('remove %',WithBlock,) do |row|
     unless row[:value_float].nil?
            row[:value_float] = row[:value_float].to_s.tr('%','')
            row[:value_float] = row[:value_float].to_f
     end
     if row[:value_float].nil?
        row[:value_float] = 'skip'
     end
     row
   end
   .transform("",WithBlock) do |row|
     row[:proficiency_band] = row[:subject]
     row
   end
   .transform('remove blank value rows', DeleteRows, :value_float, 'skip',9999)
   .transform("splicing the subject values",WithBlock) do |row|
     row[:subject] = row[:subject].to_s.gsub!(/[0-9]/,'').gsub!('_','')
     row
   end
   .transform("splicing the proficiency band values",WithBlock) do |row|
     row[:proficiency_band] = row[:proficiency_band].to_s.gsub!(/[a-z]/,'').gsub!('_','')
     row
   end
   .transform("mapping breakdown ids", 
     HashLookup,:breakdown, map_breakdown, to: :breakdown_id)
   .transform("mapping subjects",
     HashLookup, :subject, map_subject, to: :subject_id)
   .transform("mapping proficiency bands",
     HashLookup, :proficiency_band, map_prof_band, to: :proficiency_band_id)
 end

	def config_hash
		{
			source_id:30,
			state:'ms',
			notes:'DXT-2168 MS 2016 MAP EOC test load',
			url: 'http://www.mde.k12.ms.us',
			file: 'ms/2016/ms.2016.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

MSTestProcessor2016MAPEOC.new(ARGV[0],max:nil,offset:nil).run
