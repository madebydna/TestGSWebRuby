require_relative "../test_processor"
GS::ETL::Logging.disable

class METestProcessor2015SBACMEA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2015
  end


   map_tn_breakdown = {
     'All Students' => 1,
     'Black' => 3,
     'Native American' => 4,
     'Asian' => 2,
     'White' => 8,
     'Economically Disadvantaged' => 9,
     'Non-Economically Disadvantaged' => 10,
     'English Language Learners' => 15,
     'Non-English Language Learners' => 16,
     'Hispanic' => 6,
     'Students with Disabilities' => 13,
     'Non-Students with Disabilities' => 14,
     'Hawaiian or Pacific Islander' => 112
   }

   map_tn_subject = {
     'Algebra I' => 7,
     'Algebra II' => 11,
     'Biology I' => 29,
     'Chemistry' => 42,
     'English I' => 19,
     'English II' => 27,
     'English III' => 63,
     'Geometry' => 9,
     'Integrated Math I' => 8,
     'Integrated Math II' => 10,
     'Integrated Math III' => 12,
     'US History' => 30
   }

 source("ELA_grade_3_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '3',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'*')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("ELA_grade_4_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '4',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'*')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("ELA_grade_5_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '5',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'*')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("ELA_grade_6_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '6',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'*')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("ELA_grade_7_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '7',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'*')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("ELA_grade_8_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '8',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("ELA_grade_11_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '11',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'*')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("ELA_grade_All_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'ELA',
     subject_id: 4,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_ela: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("> values", WithBlock) do |row|
     if row[:value_float] == '>95%'
       row[:value_float] = '-95%'
     else row[:value_float] = row[:value_float]
     end
     row
   end
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_3_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '3',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_4_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '4',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_5_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '5',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_6_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '6',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_7_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '7',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_8_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '8',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_levels_3_or_4: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_11_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '11',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Math_grade_All_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name] == 'State Totals'
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Math',
     subject_id: 5,
     test_data_type: 'ME SBAC',
     test_data_type_id: 327
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_math: :number_tested,
       percentage_met_standard_or_met_standard_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Science_grade_5_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '5',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Science',
     subject_id: 25,
     test_data_type: 'MEA',
     test_data_type_id: 69
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_science: :number_tested,
       percentage_proficient_or_proficient_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Science_grade_8_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '8',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Science',
     subject_id: 25,
     test_data_type: 'MEA',
     test_data_type_id: 69
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_science: :number_tested,
       percentage_proficient_or_proficient_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Science_grade_11_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name].nil?
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: '11',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Science',
     subject_id: 25,
     test_data_type: 'MEA',
     test_data_type_id: 69
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_science: :number_tested,
       percentage_proficient_or_proficient_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

 source("Science_grade_All_2015.txt",[], col_sep: "\t") do |s|
   s.transform("Creating entity level", WithBlock) do |row|
     if row[:school_name] == 'State Totals'
       row[:entity_level] = 'state'
     else row[:entity_level] = 'school'
     end
     row
   end
   .transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2015,
     breakdown: 'All',
     breakdown_id: 1,
     subject: 'Science',
     subject_id: 25,
     test_data_type: 'MEA',
     test_data_type_id: 69
   })
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       school_id: :state_id,
       participant_science: :number_tested,
       percentage_proficient_or_proficient_with_distinction: :value_float
     })
   .transform("Removing * and ** values", DeleteRows,:value_float,'**')
   .transform("> values", WithBlock) do |row|
     if row[:value_float] == '>95%'
       row[:value_float] = '-95%'
     else row[:value_float] = row[:value_float]
     end
     row
   end
   .transform("Removing '%' from values", WithBlock) do |row|
     row[:value_float] = row[:value_float].gsub('%','')
     row
   end
 end

  def config_hash
    {
        source_id: 42,
        state: 'me',
        notes: 'DXT-2093: ME 2015 SBAC MEA test load.',
        url: 'Lance.Gilman@maine.gov',
        file: 'me/2015/output/me.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

METestProcessor2015SBACMEA.new(ARGV[0], max: nil).run