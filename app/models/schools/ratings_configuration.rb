class RatingsConfiguration
  # TODO move into the database
  def self.city_rating_configuration
    {"mi" => { "Detroit" => Hashie::Mash.new({
                                  rating_breakdowns: {
                                      climate: {data_type_id: 200, label: "School Climate"},
                                      status: {data_type_id: 198, label: "Academic Status"},
                                      progress: {data_type_id: 199, label: "Academic Progress"}
                                  },
                                  overall: {data_type_id: 201, label: "overall", description_key: "mi_esd_summary"}
                              })}}
  end

  def self.state_rating_configuration
    {"mi" => Hashie::Mash.new({
                                  overall: {data_type_id: 197, description_key: "mi_state_accountability_summary"}
                              })}
  end

  def self.gs_rating_configuration
    Hashie::Mash.new({
                         rating_breakdowns: {
                             test_scores: {data_type_id: 164, label: "Test score rating"},
                             progress: {data_type_id: 165, label: "Student growth rating"},
                             college_readiness: {data_type_id: 166, label: "College readiness rating"}
                         },
                         overall: {description_key: "what_is_gs_rating_summary"}
                     })
  end

  def self.preK_rating_configuration
    #Pre-k rating configuration is by state
    {"mi" => Hashie::Mash.new({
                                  star_rating: {data_type_id: 217, description_key: "mi_prek_star_rating_summary"}
                              })}
  end


  def self.fetch_city_rating_configuration school
    city_rating_config_exists?(school) ? city_rating_configuration[school.shard.to_s][school.city] : nil
  end

  def self.fetch_gs_rating_configuration
    gs_rating_configuration
  end

  def self.fetch_state_rating_configuration school
    state_rating_config_exists?(school) ? state_rating_configuration[school.shard.to_s] : nil
  end

  def self.fetch_preK_rating_configuration(school)
    preK_rating_config_exists?(school) ? preK_rating_configuration[school.shard.to_s] : nil
  end

  def self.fetch_state_rating_data_type_ids school
    state_rating_configuration = fetch_state_rating_configuration school
    state_rating_configuration.nil? ? [] : Array(state_rating_configuration.overall.data_type_id)
  end

  def self.fetch_gs_rating_data_type_ids
    gs_rating_configuration = fetch_gs_rating_configuration
    gs_rating_configuration.nil? ? [] : gs_rating_configuration.rating_breakdowns.values.map(&:data_type_id)
  end

  def self.fetch_city_rating_data_type_ids school
    city_rating_configuration = fetch_city_rating_configuration school
    city_rating_configuration.nil? ? [] : city_rating_configuration.rating_breakdowns.values.map(&:data_type_id) + Array(city_rating_configuration.overall.data_type_id)
  end

  def self.fetch_preK_rating_data_type_ids school
    preK_rating_configuration = fetch_preK_rating_configuration school
    preK_rating_configuration.nil? ? [] : Array(preK_rating_configuration.star_rating.data_type_id)
  end

  def self.city_rating_config_exists? school
    !city_rating_configuration[school.shard.to_s].nil? && !city_rating_configuration[school.shard.to_s][school.city].nil?
  end

  def self.state_rating_config_exists? school
    !city_rating_configuration[school.shard.to_s].nil?
  end

  def self.gs_rating_config_exists?
    !gs_rating_configuration.nil?
  end

  def self.preK_rating_config_exists? school
    !preK_rating_configuration[school.shard.to_s].nil?
  end

end