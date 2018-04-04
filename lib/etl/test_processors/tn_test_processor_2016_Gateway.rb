require_relative "../test_processor"

class TNTestProcessor2016Gateway < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
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

 source("tn_2016_state.txt",[], col_sep: "\t") do |s|
   s.transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2016,
     entity_level: 'state',
     test_data_type: 'GATEWAY',
     test_data_type_id: 103
   })
   .transform("Adding column breakdown_id from subgroup",
    HashLookup, :subgroup, map_tn_breakdown, to: :breakdown_id)
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       subject: :subject,
       subgroup: :breakdown,
       _valid_tests: :number_tested,
       _on_track_or_mastered_prev__proficientadvanced: :value_float
     })
   .transform("Filling in subject ids",
    HashLookup, :subject, map_tn_subject, to: :subject_id)
   .transform("Removing * and ** values", DeleteRows,:value_float,'*','**')
   .transform("Removing 'Black/Hispanic/Native American'", DeleteRows, :breakdown, 'Black/Hispanic/Native American')
 end

 source("tn_2016_district.txt",[], col_sep: "\t") do |s|
   s.transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2016,
     entity_level: 'district',
     test_data_type: 'GATEWAY',
     test_data_type_id: 103
   })
   .transform("Adding column breakdown_id from subgroup",
    HashLookup, :subgroup, map_tn_breakdown, to: :breakdown_id)
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       subject: :subject,
       subgroup: :breakdown,
       _valid_tests: :number_tested,
       _on_track_or_mastered_prev__proficientadvanced: :value_float,
       district_name: :district_name
     })
   .transform("Filling in subject ids",
    HashLookup, :subject, map_tn_subject, to: :subject_id)
   .transform("Removing * and ** values", DeleteRows,:value_float,'*','**')
   .transform("Removing 'Black/Hispanic/Native American'", DeleteRows, :breakdown, 'Black/Hispanic/Native American')
   .transform("", WithBlock) do |row|
     row[:state_id] = '%03i' % (row[:district].to_i)
     row[:district_id] = '%03i' % (row[:district].to_i)
     row
   end
 end

 source("tn_2016_school.txt",[], col_sep: "\t") do |s|
   s.transform('Fill missing default fields', Fill, {
     entity_type: 'public_charter',
     proficiency_band: 'null',
     proficiency_band_id: 'null',
     level_code: 'e,m,h',
     grade: 'All',
     year: 2016,
     entity_level: 'school',
     test_data_type: 'GATEWAY',
     test_data_type_id: 103
   })
   .transform("Adding column breakdown_id from subgroup",
    HashLookup, :subgroup, map_tn_breakdown, to: :breakdown_id)
   .transform("Renaming subject value columns", MultiFieldRenamer,
     {
       subject: :subject,
       subgroup: :breakdown,
       _valid_tests: :number_tested,
       _on_track_or_mastered_prev__proficientadvanced: :value_float,
       district_name: :district_name,
       school_name: :school_name
     })
   .transform("Filling in subject ids",
    HashLookup, :subject, map_tn_subject, to: :subject_id)
   .transform("Removing * and ** values", DeleteRows,:value_float,'*','**')
   .transform("Removing 'Black/Hispanic/Native American'", DeleteRows, :breakdown, 'Black/Hispanic/Native American')
   .transform("Padding school and district ids", WithBlock) do |row|
     row[:school] = '%04i' % (row[:school].to_i)
     row[:district] = '%03i' % (row[:district].to_i)
     row
   end
   .transform("Creating state school and district ids", WithBlock) do |row|
     row[:state_id] = row[:district] + row[:school]
     row[:school_id] = row[:district] + row[:school]
     row[:district_id] = row[:district]
     row
   end
 end


  def config_hash
    {
        source_id: 34,
        state: 'tn',
        notes: 'DXT-2069: TN Gateway 2016 test load.',
        url: 'http://www.tn.gov/education/topic/data-downloads',
        file: 'tn/2016/output/tn.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

TNTestProcessor2016Gateway.new(ARGV[0], max: nil).run