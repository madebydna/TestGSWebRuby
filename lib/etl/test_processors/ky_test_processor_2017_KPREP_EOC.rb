require_relative "../test_processor"
GS::ETL::Logging.disable

class KYTestProcessor2017KPREPEOC < GS::ETL::TestProcessor

	def initialize(*args)
		super
		@year=2017
	end

	map_subject = {
		'Algebra II' => 11,
		'English II' => 27,
    'Biology' => 29,
    'U.S. History' => 30
	}

  map_gsdata_academic = {
    'Algebra II' => 10,
    'English II' => 21,
    'Biology' => 22,
    'U.S. History' => 23
  }


	map_breakdown = {
		'All Students' => 1,
		'Asian' => 2,
		'African American' => 3,
		'Female' => 11,
		'Free/Reduced-Price Meals' => 9,
		'Hispanic' => 6,
		'English Learners' => 15,
		'Male' => 12,
		'American Indian or Alaska Native' => 4,
		'Disability-With IEP (total)' => 13,
		'White (Non-Hispanic)' => 8,
    'Two or more races' => 21,
    'Native Hawaiian or Other Pacific Islander' => 112
	}

  map_gsdata_breakdown = {
    'All Students' => 1,
    'Asian' => 16,
    'African American' => 17,
    'Female' => 26, 
    'Free/Reduced-Price Meals' => 23,
    'Hispanic' => 19,
    'English Learners' => 32,
    'Male' => 25,
    'American Indian or Alaska Native' => 18,
    'Disability-With IEP (total)' => 27,
    'White (Non-Hispanic)' => 21,
    'Two or more races' => 22,
    'Native Hawaiian or Other Pacific Islander' => 20

  }



 source('ky_eoc.txt',[],col_sep:"\t")  do |s|
   s.transform("setting entity level", WithBlock) do |row|
     if row[:sch_name] == '---State Total---'
       row[:entity_level] = 'state'
     elsif row[:sch_name] == '---District Total---'
       row [:entity_level] = 'district'
     else
       row[:entity_level] = 'school'
     end
     row
   end
   .transform("Fill Columns",Fill,
     {
       year: 2017,
       entity_type: 'public_charter',
       level_code: 'e,m,h',
       test_data_type: 'EOC',
       test_data_type_id: 213,
       gsdata_test_data_type_id: 313,
       notes: 'DXT-2569: KY EOC',
       description: 'In 2016-2017, Kentucky administered the End-of-Course (EOC) assessments. EOCs are tests given to public high school students when they complete a course to assess their knowledge of important course concepts. They are similar to a final exam, except that they are created and scored by an outside testing company, ensuring that the tests are both rigorous and aligned with state and national college readiness standards.'
     })
   .transform("create state id",WithBlock) do |row|
     if row[:entity_level] == 'school'
       row[:state_id] = row[:state_sch_id]
       row[:school_id] = row[:state_id]
       row[:school_name] = row[:sch_name]
       row[:district_name] = row[:dist_name]
     elsif row[:entity_level] == 'district'
       row[:state_id] = row[:cntyno] + row[:dist_number] + '000'
       row[:district_id] = row[:state_id]
       row[:district_name] = row[:dist_name]
       row[:school_id] = 'district'
     else
       row[:state_id] = 'state'
       row[:district_id] = 'state'
       row[:school_id] = 'state'
     end
     row
   end
   .transform("rename fields",MultiFieldRenamer,
     {
       content_type: :subject,
       disagg_label: :breakdown
     })
   .transform('delete unwanted coop school rows', DeleteRows, :sch_name, '---COOP Total---')
   .transform('delete unwanted breakdown rows', DeleteRows, :breakdown, 'Migrant','Homeless','Gifted/Talented','Gap Group (non-duplicated)','Disability - With IEP (not including Alternate)','Disability - With Accommodation (not including Alternate)','Disability - Alternate Only')
   .transform('find blank values',WithBlock) do |row|
     if row[:pct_proficient_distinguished] == ''
       row[:pct_proficient_distinguished] = 'skip'
     end
     row
   end
   .transform('delete unwanted blank rows', DeleteRows, :pct_proficient_distinguished, 'skip')
   .transform('transposing prof columns', Transposer, :proficiency_band, :value_float, :pct_novice, :pct_apprentice, :pct_proficient, :pct_distinguished, :pct_proficient_distinguished, :black_percent, :hispanic_percent, :two_or_more_races_percent, :white_percent, :eds_percent, :lep_percent, :swd_percent)
   .transform("rename fields",MultiFieldRenamer,
     {
       nbr_tested: :number_tested
     })
   .transform('fix breakdowns',WithBlock) do |row|
     row[:breakdown] = row[:breakdown].to_s.gsub('_',' ').gsub(' percent','')
     row
   end
   .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform('mapping breakdowns', HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping subjects', HashLookup, :subject, map_subject, to: :subject_id)
   .transform('mapping subjects', HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id)
 end


def config_hash
  {
    source_id: 24,
    source_name: 'Kentucky Department of Education',
    date_valid: '2017-01-01 00:00:00',
    state:'ky',
    url: 'http://www.education.ky.gov',
    file: 'ky/2017/ky.2017.1.public.charter.[level].txt',
    level: nil,
    school_type: 'public,charter'
  }
end



end

KYTestProcessor2017KPREPEOC.new(ARGV[0],max:nil,offset:nil).run
