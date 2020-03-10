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
    'U.S. History' => 30,
    'Language Mechanics' => 81,
    'Mathematics' => 5,
    'Reading' => 2,
    'Social Studies' => 24,
    'Writing' => 3
	}

  map_gsdata_academic = {
    'Algebra II' => 10,
    'English II' => 21,
    'Biology' => 22,
    'U.S. History' => 23,
    'Language Mechanics' => 66,
    'Mathematics' => 5,
    'Reading' => 2,
    'Social Studies' => 18,
    'Writing' => 3
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
		'Disability-With IEP (Total)' => 13,
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
    'Disability-With IEP (Total)' => 27,
    'White (Non-Hispanic)' => 21,
    'Two or more races' => 22,
    'Native Hawaiian or Other Pacific Islander' => 20
  }

  map_proficiency_band_id = {
  :pct_novice => 176,
  :pct_apprentice => 177,
  :pct_proficient => 178,
  :pct_distinguished => 179,
  :pct_proficient_distinguished => 'null'
  }

  map_gsdata_proficiency_band_id = {
  :pct_novice => 134,
  :pct_apprentice => 135,
  :pct_proficient => 136,
  :pct_distinguished => 137,
  :pct_proficient_distinguished => 1
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
       grade: 'All',
       test_data_type: 'EOC',
       test_data_type_id: 213,
       gsdata_test_data_type_id: 313,
       notes: 'DXT-2569: KY EOC',
       description: 'In 2016-2017, Kentucky administered the End-of-Course (EOC) assessments. EOCs are tests given to public high school students when they complete a course to assess their knowledge of important course concepts. They are similar to a final exam, except that they are created and scored by an outside testing company, ensuring that the tests are both rigorous and aligned with state and national college readiness standards.'
     })
 end

source('ky_eog.txt',[],col_sep:"\t")  do |s|
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
       test_data_type: 'K-PREP',
       test_data_type_id: 212,
       gsdata_test_data_type_id: 312,
       notes: 'DXT-2569: KY K-PREP',
       description: 'In 2016-2017, Kentucky used the Kentucky Performance Rating for Educational Progress (K-PREP) tests to assess students in grades 3 through 8 in reading and mathematics, 4 and 7 in science, 5 and 8 in social studies, 5, 6, 8, 10, and 11 in writing, and 4, 6, and 10 in language mechanics. The K-PREP is a standards-based test, which means it measures how well students are mastering specific skills defined for each grade by the state of Kentucky.'
     })
   .transform("rename grade field",MultiFieldRenamer,
     {
       grade_level: :grade
     })
   .transform("strip 0 from grades",WithBlock) do |row|
     row[:grade] = row[:grade].gsub('0','')
     row
   end
 end

shared do |s|
   s.transform("create state id",WithBlock) do |row|
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
   .transform('delete unwanted breakdown rows', DeleteRows, :breakdown, 'Migrant','Homeless','Gifted/Talented','Gap Group (non-duplicated)','Disability-With IEP (not including Alternate)','Disability-With Accommodation (not including Alternate)','Disability-Alternate Only')
   .transform('find blank values',WithBlock) do |row|
     if row[:pct_proficient_distinguished].nil?
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
     row[:number_tested] = row[:number_tested].gsub('"','').gsub(',','')
     row
   end
   .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
   .transform('mapping breakdowns', HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
   .transform('mapping subjects', HashLookup, :subject, map_subject, to: :subject_id)
   .transform('mapping subjects', HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id)
   .transform('mapping prof bands', HashLookup, :proficiency_band, map_proficiency_band_id, to: :proficiency_band_id)
   .transform('mapping prof bands', HashLookup, :proficiency_band, map_gsdata_proficiency_band_id, to: :proficiency_band_gsdata_id)
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
