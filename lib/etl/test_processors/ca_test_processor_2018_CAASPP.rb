require_relative "../test_processor"

class CATestProcessor2018CAASPP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  key_map_bd = {
    '1' => 1,
    '3' => 25,
    '4' => 26,
    '6' => 2,
    '7' => 11,
    '8' => 12,
    '31' => 23,
    '74' => 17,
    '75' => 18,
    '76' => 16,
    '77' => 38,
    '78' => 19,
    '79' => 20,
    '80' => 21,
    '90' => 57,
    '91' => 58,
    '92' => 59,
    '93' => 60,
    '94' => 61,
    '99' => 30,
    '111' => 24,
    '120' => 13,
    '121' => 62,
    '128' => 27,
    '142' => 14,
    '144' => 22,
    '160' => 32,
    '180' => 33
  }

  key_map_sub = {
    '1' => 4,
    '2' => 5
  }

  key_map_pro = {
    :"percentage_standard_exceeded" => 50,
    :"percentage_standard_met" => 49,
    :"percentage_standard_nearly_met" => 48,
    :"percentage_standard_not_met" => 47,
    :"percentage_standard_met_and_above" => 1,
  }


  source("ca_sub_schools.txt",[], col_sep: "\t") do |s|
    s.transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :percentage_standard_exceeded,
       :percentage_standard_met,
       :percentage_standard_nearly_met,
       :percentage_standard_not_met,
       :percentage_standard_met_and_above
       )
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        subgroup_id: :breakdown,
        test_id: :subject,
        students_tested: :number_tested
      })
    .transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2018,
      test_data_type: 'CAASPP',
      gsdata_test_data_type_id: 299,
      notes: 'DXT-2857: CA CAASPP',
      description: 'In 2017-2018, California tested students using the California Assessment of Student Performance and Progress (CAASPP), administered through the online Smarter Balanced Summative Assessments. These are comprehensive, end-of-year assessments of grade-level learning that measure progress toward college and career readiness. Each test, English language arts/literacy (ELA) and mathematics is comprised of two parts: (1) a computer adaptive test and (2) a performance task; administered within a 12-week window beginning at 66 percent of the instructional year for grades three through eight, or within in a 7-week window beginning at 80 percent of the instructional year for grade eleven. The summative assessments are aligned with the Common Core State Standards (CCSS) for ELA and mathematics. The tests capitalize on the strengths of computer adaptive testing-efficient and precise measurement across the full range of achievement and timely turnaround of results.'
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_gsdata_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :academic_gsdata_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_gsdata_id)
    .transform("Creating StateID", WithBlock) do |row|
      row[:state_id] = row[:county_code]+row[:district_code]+row[:school_code]
      row
    end
  end


  source("ca_sub_districts.txt",[], col_sep: "\t") do |s|
    s.transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :percentage_standard_exceeded,
       :percentage_standard_met,
       :percentage_standard_nearly_met,
       :percentage_standard_not_met,
       :percentage_standard_met_and_above
       )
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        subgroup_id: :breakdown,
        test_id: :subject,
        students_tested: :number_tested
      })
    .transform('Fill missing default fields', Fill, {
      entity_level: 'district',
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2018,
      test_data_type: 'CAASPP',
      gsdata_test_data_type_id: 299,
      notes: 'DXT-2857: CA CAASPP',
      description: 'In 2017-2018, California tested students using the California Assessment of Student Performance and Progress (CAASPP), administered through the online Smarter Balanced Summative Assessments. These are comprehensive, end-of-year assessments of grade-level learning that measure progress toward college and career readiness. Each test, English language arts/literacy (ELA) and mathematics is comprised of two parts: (1) a computer adaptive test and (2) a performance task; administered within a 12-week window beginning at 66 percent of the instructional year for grades three through eight, or within in a 7-week window beginning at 80 percent of the instructional year for grade eleven. The summative assessments are aligned with the Common Core State Standards (CCSS) for ELA and mathematics. The tests capitalize on the strengths of computer adaptive testing-efficient and precise measurement across the full range of achievement and timely turnaround of results.'
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_gsdata_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :academic_gsdata_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_gsdata_id)
    .transform("Creating StateID", WithBlock) do |row|
      row[:state_id] = row[:county_code]+row[:district_code]
      row
    end
  end

  source("ca_sub_state.txt",[], col_sep: "\t") do |s|
    s.transform('Transpose value columns', Transposer,
       :proficiency_band,
       :value_float,
       :percentage_standard_exceeded,
       :percentage_standard_met,
       :percentage_standard_nearly_met,
       :percentage_standard_not_met,
       :percentage_standard_met_and_above
       )
    .transform("Renaming fields",
      MultiFieldRenamer,
      {
        subgroup_id: :breakdown,
        test_id: :subject,
        students_tested: :number_tested
      })
    .transform('Fill missing default fields', Fill, {
      entity_level: 'state',
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      year: 2018,
      test_data_type: 'CAASPP',
      gsdata_test_data_type_id: 299,
      notes: 'DXT-2857: CA CAASPP',
      description: 'In 2017-2018, California tested students using the California Assessment of Student Performance and Progress (CAASPP), administered through the online Smarter Balanced Summative Assessments. These are comprehensive, end-of-year assessments of grade-level learning that measure progress toward college and career readiness. Each test, English language arts/literacy (ELA) and mathematics is comprised of two parts: (1) a computer adaptive test and (2) a performance task; administered within a 12-week window beginning at 66 percent of the instructional year for grades three through eight, or within in a 7-week window beginning at 80 percent of the instructional year for grade eleven. The summative assessments are aligned with the Common Core State Standards (CCSS) for ELA and mathematics. The tests capitalize on the strengths of computer adaptive testing-efficient and precise measurement across the full range of achievement and timely turnaround of results.'
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_gsdata_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :academic_gsdata_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_gsdata_id)
  end


  def config_hash
    {
        gsdata_source_id: 8,
        state: 'ca',
        source_name: 'California Department of Education',
        date_valid: '2018-01-01 00:00:00',
        notes: 'DXT-2857: CA CAASPP 2018 test load',
        url: 'http://caaspp.cde.ca.gov/sb2016/ResearchFileList',
        file: 'ca/2018/output/ca.2018.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

CATestProcessor2018CAASPP.new(ARGV[0], max: nil).run
