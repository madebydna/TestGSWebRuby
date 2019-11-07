require_relative "../test_processor"

class CTTestProcessor201720182019CMTSBAC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
  end

  source("cmt_17.txt",[],col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3129: CT CMT',
      test_data_type: 'CMT',
      test_data_type_id: '246',
      proficiency_band_id: 1
    })
  end

  source("sbac_171819.txt",[],col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      notes: 'DXT-3129: CT SBAC',
      test_data_type: 'SBAC',
      test_data_type_id: '248',
      proficiency_band_id: 1
    })
  end

  def config_hash
    {
      source_id: 10,
      state: 'ct'
    }
  end
end

CTTestProcessor201720182019CMTSBAC.new(ARGV[0], max: nil).run