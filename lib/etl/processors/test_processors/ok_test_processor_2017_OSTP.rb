require_relative "../test_processor"

class OKTestProcessor2017OSTP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  source("ok_ostp.txt",[],col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      date_valid: '2017-01-01 00:00:00',
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
      notes: 'DXT-3091: OK OSTP',
      test_data_type: 'OSTP',
      test_data_type_id: '363',
      description: 'In 2016-17, the Oklahoma State Department of Education administered assessments through the Oklahoma School Testing Program (OSTP) to provide evidence of student proficiency of grade-level standards to inform progress toward career- and college-readiness (CCR) and support student and school accountability. State assessment scores provide a reliable measure that can be compared across schools and districts by serving as a point-in-time snapshot of what students know and can do relative to the Oklahoma Academic Standards. The OSTP was administered to students in English Language Arts and Mathematics in grades 3-8, and grade 10. The test was also administered to students in Science in grades 5, 8, and 10, and in US History in grade 10.'
    })
  end

  def config_hash
    {
      source_id: 41,
      state: 'ok'
    }
  end
end

OKTestProcessor2017OSTP.new(ARGV[0], max: nil).run