require_relative "../test_processor"

class MOTestProcessor20182019MAP_MAPEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  map_breakdown = {
    'Amer. Indian or Alaska Native' => 18,
    'Asian/Pacific Islander' => 15,
    'Black (not Hispanic)' => 17,
    'Hispanic' => 19,
    'Multiracial' => 22,
    'White (not Hispanic)' => 21,
    'LEP/ELL Students' => 32,
    'ELL Students' => 32,
    'IEP Students' => 27,
    'IEP_student' => 27,
    'Non IEP Students' => 30,
    'Map Free and Reduced Lunch' => 23,
    'Non Free and Reduced Lunch' => 24,
    'Total' => 1
  }
  
  map_subject = {
   'Eng. Language Arts' => 4,
   'Mathematics' => 5,
   'Science' => 19,
   'AH' => 23,
   'GV' => 56,
   'A1' => 6,
   'A2' => 10,
   'E1' => 17,
   'E2' => 21,
   'GE' => 8,
   'B1' => 22,
   'PS' => 24
  }

  source("map_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3374: MO MAP',
      test_data_type: 'MAP',
      test_data_type_id: '228',
    })
    .transform("assign description", WithBlock) do |row|
      if row[:year] == '2018'
        row[:description] = 'The 2017-2018 Missouri Assessment Program assesses students progress toward mastery of the Show-Me Standards which are the educational standards in Missouri. The Grade-Level Assessment is a yearly standards-based test that measures specific skills defined for each grade by the state of Missouri. All students in grades 3-8 and 11 in Missouri will take the grade level assessment. English Language Arts and Mathematics are administered in all grades.'
      else
        row[:description] = 'The 2018-2019 Missouri Assessment Program assesses students progress toward mastery of the Show-Me Standards which are the educational standards in Missouri. The Grade-Level Assessment is a yearly standards-based test that measures specific skills defined for each grade by the state of Missouri. All students in grades 3-8 and 11 in Missouri will take the grade level assessment in English Language Arts and Mathematics. All students in grades 5, 8, and 11 will take the grade level assessment in Science.'
      end
      row
    end
    .transform('mapping subjects', HashLookup, :content_area, map_subject, to: :subject_id)
  end

  source("map_eoc_2018_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3374: MO MAP EOC',
      test_data_type: 'MAP EOC',
      test_data_type_id: '229',
      grade: 'All'

    })
    .transform("assign description", WithBlock) do |row|
      if row[:year] == '2018'
        row[:description] = 'The 2017-2018 Missouri Assessment Program assesses students progress toward mastery of the Show-Me Standards which are the educational standards in Missouri. The Grade-Level Assessment is a yearly standards-based test that measures specific skills defined for each grade by the state of Missouri. All students in grades 3-8 and 11 in Missouri will take the grade level assessment. English Language Arts and Mathematics are administered in all grades.'
      else
        row[:description] = 'The 2018-2019 Missouri Assessment Program assesses students progress toward the Missouri Learning Standards, which are Missouri content standards. End-of-Course assessments are taken when a student has received instruction on the Missouri Learning Standards for an assessment, regardless of grade level. Missouri suite of available End-of-Course assessments includes: English I, English II, Algebra I, Algebra II, Geometry, Biology, and Physical Science.'
      end
      row
    end
    .transform('mapping subjects for EOC', HashLookup, :grade_level, map_subject, to: :subject_id)
  end

  shared do |s|
    s.transform("renaming fields",
      MultiFieldRenamer,
      {
        prof_above: :value,
        type: :breakdown,
        content_area: :subject,
        grade_level: :grade,
        reportable: :number_tested,
        school_code: :school_id,
        county_district: :district_id
      })
    .transform('fill missing default fields', Fill, {
        proficiency_band_id: 1
    })
    .transform("fix value", WithBlock) do |row|
      if row[:value].to_f < 0.1
        row[:value] = 0
      elsif row[:value].to_f > 100
        row[:value] = 100
      end
      row[:value] = row[:value]
      row
    end  
    .transform('mapping breakdowns', HashLookup, :breakdown, map_breakdown, to: :breakdown_id)
    .transform("creating StateID", WithBlock) do |row|
      if row[:entity_type] == 'district'
        row[:state_id] = row[:district_id]
        row[:school_id] = nil
      elsif row[:entity_type] == 'school'
        row[:state_id] = row[:school_id]+row[:district_id]
        row[:school_id] = row[:state_id]
        row[:district_id] = nil
      else
        row[:school_id] = nil
        row[:district_id] = nil
      end
      row
    end
  end

  def config_hash
    {
        source_id: 29,
        state: 'mo'
    }
  end
end

MOTestProcessor20182019MAP_MAPEOC.new(ARGV[0], max: nil).run
