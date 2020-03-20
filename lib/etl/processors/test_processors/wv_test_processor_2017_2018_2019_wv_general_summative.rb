require_relative "../test_processor"

class WVTestProcessor201720182019WVGeneralSummative < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  source("wv_summative_17.txt",[],col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      date_valid: '2017-01-01 00:00:00',
      description: "In 2016-2017, students in West Virginia took the General Summative Assessment. The West Virginia General Summative Assessment, includes the Smarter Balanced assessments in reading and mathematics, for students in grades 3-8 and grade 11."
    })
  end

  source("wv_summative_18.txt",[],col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      date_valid: '2018-01-01 00:00:00',
      description: "In 2017-2018, students in West Virginia took the General Summative Assessment. The West Virginia General Summative Assessment was administered to students in Grades 3-8 in reading and mathematics."
    })
  end

  source("wv_summative_19.txt",[],col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      date_valid: '2019-01-01 00:00:00',
      description: "In 2018-2019, students in West Virginia took the General Summative Assessment. The West Virginia General Summative Assessment was administered to students in Grades 3-8 in reading and mathematics, and grades 5 and 8 in science."
    })
  end

  shared do |s| 
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3322: WV General Summative',
      test_data_type: 'WV General Summative',
      test_data_type_id: '211',
    })
  end

  def config_hash
    {
      source_id: 53,
      state: 'wv'
    }
  end
end

WVTestProcessor201720182019WVGeneralSummative.new(ARGV[0], max: nil).run