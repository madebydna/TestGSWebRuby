require_relative "../test_processor"

class CATestProcessor2019CAASPP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  source("ca_test_school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00'
    })
  end

  source("ca_test_district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00'
    })
  end

  source("ca_test_state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00'
    })
  end


  def config_hash
    {
        source_id: 8,
        state: 'ca'
    }
  end
end

CATestProcessor2019CAASPP.new(ARGV[0], max: nil).run
