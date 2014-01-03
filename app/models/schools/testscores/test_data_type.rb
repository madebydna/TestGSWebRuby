class TestDataType < ActiveRecord::Base
  self.table_name = 'TestDataType'
  db_magic :connection => :gs_schooldb
  attr_accessible :description, :display_name, :display_type, :name, :type
  has_many :test_data_sets, class_name: 'TestDataSet', foreign_key: 'data_type_id'
  #bad_attribute_names :type
  #self.inheritance_column = nil
  self.inheritance_column = :_type_disabled
  def self.by_id(data_type_ids)
    begin
      TestDataType.find(data_type_ids)
    rescue
      Rails.logger.debug "Could not locate TestDataType for id #{data_type_ids}"
    end
  end

  def self.city_rating_configuration
    {"mi" => Hashie::Mash.new({
                                  rating_breakdowns: {
                                      climate: {data_type_id: 200, label: "Climate"},
                                      status: {data_type_id: 198, label: "Status"},
                                      progress: {data_type_id: 199, label: "Progress"}
                                  },
                                  overall: {data_type_id: 201, label: "overall", description_key: "mi_esd_summary"}
                              })}
  end

  def self.state_rating_configuration
    {"mi" => Hashie::Mash.new({
                         overall: {data_type_id: 197, description_key: "mi_state_accountability_summary"}
                     })}
    #{ "mi" => [197]}
  end

  def self.gs_rating_configuration
    Hashie::Mash.new({
                         rating_breakdowns: {
                             test_scores: {data_type_id: 164, label: "Test Scores"},
                             progress: {data_type_id: 165, label: "Progress"},
                             college_readiness: {data_type_id: 166, label: "College Readiness"}
                         },
                         overall: {description_key: "what_is_gs_rating_summary"}
                     })

    #[164, 165, 166]
  end
end
