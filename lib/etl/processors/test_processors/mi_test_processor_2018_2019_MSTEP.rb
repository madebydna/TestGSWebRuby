require_relative "../test_processor"

class MITestProcessor20182019MSTEP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  breakdown_id_map = {
      "All Students" => 1,
      "Black or African American" => 17,
      "American Indian or Alaska Native" => 18,
      "Asian" => 16,
      "White" => 21,
      "Hispanic or Latino" => 19,
      "Hispanic of Any Race" => 19,
      "Two or More Races" => 22,
      "Female" => 26,
      "Male" => 25,
      "English Language Learners" => 32,
      "English Learners" => 32,
      "Not English Learners" => 33,
      "Native Hawaiian or Other Pacific Islander" => 20,
      "Economically Disadvantaged" => 23,
      "Not Economically Disadvantaged" => 24,
      "Students with Disabilities" => 27,
      "Students With Disabilities" => 27,
      "All Except Students with Disabilities" => 30,
      "Students Without Disabilities" => 30

  }

  subject_id_map = {
      "English Language Arts" => 4,
      "ELA" => 4,
      "Mathematics" => 5,
      "Social Studies" => 18,
      "Science" => 19
  }

  source("tidy_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      description: 'In 2017-2018, students in Michigan took the Michigan Student Test of Educational Progress, or M-STEP. The M-STEP includes a summative assessments designed to measure student growth effectively for today\'s students. English language arts and mathematics will be assessed in grades 3-8, science in grades 4 and 7, and social studies in grades 5 and 8. It also includes the Michigan Merit Examination in 11th grade, which consists of a college entrance exam, work skills assessment, and M-STEP summative assessments in science, and social studies.'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      demographic_group: :breakdown,
      content_area_name: :subject
    })
  end

  source("tidy_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      description: 'In 2018-2019, students in Michigan took the Michigan Student Test of Educational Progress, or M-STEP. The M-STEP includes a summative assessments designed to measure student growth effectively for today\'s students. English language arts and mathematics will be assessed in grades 3-8, science in grades 4 and 7, and social studies in grades 5 and 8. It also includes the Michigan Merit Examination in 11th grade, which consists of a college entrance exam, work skills assessment, and M-STEP summative assessments in English language arts, mathematics, science, and social studies.'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      report_category: :breakdown
    })
  end

  shared do |s| 
    s.transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
      test_data_type: 'M-STEP',
      test_data_type_id: 282,
      notes: 'DXT-3403: MI M-STEP'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      prof_above: :value
    })
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id) 
  end

  def config_hash
    {
      source_id: 26,
      state: 'mi'
    }
  end
end

MITestProcessor20182019MSTEP.new(ARGV[0], max: nil).run