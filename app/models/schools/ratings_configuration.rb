class RatingsConfiguration

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
  end

end