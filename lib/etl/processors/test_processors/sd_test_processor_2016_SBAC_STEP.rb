require_relative "../test_processor"
GS::ETL::Logging.disable

class SDTestProcessor2016SBACSTEP < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2016
	end

	map_proficiency = {
    '0' => 'null',
		'4' => 37,
		'3' => 36,
		'2' => 35,
		'1' => 34
	}


	map_breakdown = {
		'all' => 1,
		'as' => 2,
		'bl' => 3,
		'fm' => 11,
		'fr' => 9,
		'hs' => 6,
		'en' => 15,
		'ma' => 12,
		'nt' => 4,
		'pc' => 112,
		'ds' => 13,
		'wh' => 8,
    'tw' => 21
	}


 source('sd_ela_sch_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'school',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'SD SBAC',
       test_data_type_id: 249,
       subject: 'ela',
       subject_id: 4
     })
   .transform("creating state id", WithBlock) do |row|
     row[:state_id] = '%05i' % (row[:county_district_number].to_i) + '%02i' % (row[:school_number].to_i)
     row
   end
 end

 source('sd_ela_dist_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'district',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'SD SBAC',
       test_data_type_id: 249,
       subject: 'ela',
       subject_id: 4
     })
   .transform("creating state id", WithBlock) do |row|
     row[:state_id] = '%05i' % (row[:county_district_number].to_i)
     row
   end
 end

 source('sd_ela_state_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'state',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'SD SBAC',
       test_data_type_id: 249,
       subject: 'ela',
       subject_id: 4
     })
 end

 source('sd_math_sch_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'school',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'SD SBAC',
       test_data_type_id: 249,
       subject: 'math',
       subject_id: 5
     })
   .transform("creating state id", WithBlock) do |row|
     row[:state_id] = '%05i' % (row[:county_district_number].to_i) + '%02i' % (row[:school_number].to_i)
     row
   end
 end

 source('sd_math_dist_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'district',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'SD SBAC',
       test_data_type_id: 249,
       subject: 'math',
       subject_id: 5
     })
    .transform("creating state id", WithBlock) do |row|
     row[:state_id] = '%05i' % (row[:county_district_number].to_i)
     row
   end
 end

 source('sd_math_state_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'state',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'SD SBAC',
       test_data_type_id: 249,
       subject: 'math',
       subject_id: 5
     })
 end

 source('sd_science_sch_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'school',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'STEP',
       test_data_type_id: 83,
       subject: 'science',
       subject_id: 25
     })
   .transform("creating state id", WithBlock) do |row|
     row[:state_id] = '%05i' % (row[:county_district_number].to_i) + '%02i' % (row[:school_number].to_i)
     row
   end
 end

 source('sd_science_dist_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'district',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'STEP',
       test_data_type_id: 83,
       subject: 'science',
       subject_id: 25
     })
   .transform("creating state id", WithBlock) do |row|
     row[:state_id] = '%05i' % (row[:county_district_number].to_i)
     row
   end
 end

 source('sd_science_state_2016.txt',[],col_sep:"\t")  do |s|
   s.transform("Fill Columns",Fill,
     {
       entity_level: 'state',
       year: 2016,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'STEP',
       test_data_type_id: 83,
       subject: 'science',
       subject_id: 25
     })
 end

 shared do |s|
   s.transform('fixing grade', WithBlock) do |row|
     if row[:grade] == ' .'
       row[:grade] = 'All'
     else row[:grade] = row[:grade]
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
      if row[:all_4] == '  .'
        row[:all_4] = '1000'
        row[:all_3] = '1000'
        row[:all_2] = '1000'
        row[:all_1] = '1000'
      end
      row
    end
   .transform('fixing . values', WithBlock) do |row|
      if row[:wh_4] == '  .'
        row[:wh_4] = '1000'
        row[:wh_3] = '1000'
        row[:wh_2] = '1000'
        row[:wh_1] = '1000'
      end
      row
    end
   .transform('fixing . values', WithBlock) do |row|
     if row[:bl_4] == '  .'
       row[:bl_4] = '1000'
       row[:bl_3] = '1000'
       row[:bl_2] = '1000'
       row[:bl_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:as_4] == '  .'
       row[:as_4] = '1000'
       row[:as_3] = '1000'
       row[:as_2] = '1000'
       row[:as_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:nt_4] == '  .'
       row[:nt_4] = '1000'
       row[:nt_3] = '1000'
       row[:nt_2] = '1000'
       row[:nt_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:hs_4] == '  .'
       row[:hs_4] = '1000'
       row[:hs_3] = '1000'
       row[:hs_2] = '1000'
       row[:hs_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:pc_4] == '  .'
       row[:pc_4] = '1000'
       row[:pc_3] = '1000'
       row[:pc_2] = '1000'
       row[:pc_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:tw_4] == '  .'
       row[:tw_4] = '1000'
       row[:tw_3] = '1000'
       row[:tw_2] = '1000'
       row[:tw_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:fr_4] == '  .'
       row[:fr_4] = '1000'
       row[:fr_3] = '1000'
       row[:fr_2] = '1000'
       row[:fr_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:en_4] == '  .'
       row[:en_4] = '1000'
       row[:en_3] = '1000'
       row[:en_2] = '1000'
       row[:en_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:ma_4] == '  .'
       row[:ma_4] = '1000'
       row[:ma_3] = '1000'
       row[:ma_2] = '1000'
       row[:ma_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:fm_4] == '  .'
       row[:fm_4] = '1000'
       row[:fm_3] = '1000'
       row[:fm_2] = '1000'
       row[:fm_1] = '1000'
     end
     row
   end
   .transform('fixing . values', WithBlock) do |row|
     if row[:ds_4] == '  .'
       row[:ds_4] = '1000'
       row[:ds_3] = '1000'
       row[:ds_2] = '1000'
       row[:ds_1] = '1000'
     end
     row
   end
   .transform('creating null prof band', SumValues, :all_0, :all_4, :all_3)
   .transform('creating null prof band', SumValues, :wh_0, :wh_4, :wh_3)
   .transform('creating null prof band', SumValues, :bl_0, :bl_4, :bl_3)
   .transform('creating null prof band', SumValues, :as_0, :as_4, :as_3)
   .transform('creating null prof band', SumValues, :nt_0, :nt_4, :nt_3)
   .transform('creating null prof band', SumValues, :hs_0, :hs_4, :hs_3)
   .transform('creating null prof band', SumValues, :pc_0, :pc_4, :pc_3)
   .transform('creating null prof band', SumValues, :tw_0, :tw_4, :tw_3)
   .transform('creating null prof band', SumValues, :fr_0, :fr_4, :fr_3)
   .transform('creating null prof band', SumValues, :en_0, :en_4, :en_3)
   .transform('creating null prof band', SumValues, :ma_0, :ma_4, :ma_3)
   .transform('creating null prof band', SumValues, :fm_0, :fm_4, :fm_3)
   .transform('creating null prof band', SumValues, :ds_0, :ds_4, :ds_3)
   .transform('transposing prof columns', Transposer, :breakdown, :value_float, :all_0, :all_4, :all_3, :all_2, :all_1, :wh_0, :wh_4, :wh_3, :wh_2, :wh_1, :bl_0, :bl_4, :bl_3, :bl_2, :bl_1, :as_0, :as_4, :as_3, :as_2, :as_1, :nt_0, :nt_4, :nt_3, :nt_2, :nt_1, :hs_0, :hs_4, :hs_3, :hs_2, :hs_1, :pc_0, :pc_4, :pc_3, :pc_2, :pc_1, :tw_0, :tw_4, :tw_3, :tw_2, :tw_1, :fr_0, :fr_4, :fr_3, :fr_2, :fr_1, :en_0, :en_4, :en_3, :en_2, :en_1, :ma_0, :ma_4, :ma_3, :ma_2, :ma_1, :fm_0, :fm_4, :fm_3, :fm_2, :fm_1, :ds_0, :ds_4, :ds_3, :ds_2, :ds_1)
   .transform('delete suppressed values', DeleteRows, :value_float, '1000')
   .transform('delete suppressed values', DeleteRows, :value_float, 2000.0)
   .transform('altering breakdown values', WithBlock) do |row|
     row[:proficiency_band] = row[:breakdown].to_s.tr('/[^[a-z]+_]/','')
     row[:breakdown] = row[:breakdown].to_s.tr('/[_[0-9]$]/','')
     row
   end
   .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform('mapping proficiency band', HashLookup, :proficiency_band, map_proficiency, to: :proficiency_band_id)
   .transform('deleting number tested when not breakdown all', WithBlock) do |row|
     if row[:breakdown] == 'all'
       row[:number_tested] = row[:number_tested]
     else row[:number_tested] = 'null'
     end
     row
   end
  .transform('delete grade 12', DeleteRows, :grade, '12')
 end



	def config_hash
		{
			source_id: 74,
			state:'sd',
			notes:'DXT-2205 SD SBAC STEP 2016',
			url: 'https://sis.ddncampus.net:8081',
			file: 'sd/2016/sd.2016.1.public.charter.[level].txt',
			level: nil,
			school_type: 'public,charter'
		}
	end
end

SDTestProcessor2016SBACSTEP.new(ARGV[0],max:nil,offset:nil).run
