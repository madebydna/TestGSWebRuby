class RatingsConfiguration

  attr_accessor :city_rating_configuration, :state_rating_configuration, :gs_rating_configuration, :prek_rating_configuration, :city

  def initialize(city_rating_configuration,state_rating_configuration,gs_rating_configuration,prek_rating_configuration)
    @city_rating_configuration = city_rating_configuration
    @state_rating_configuration = state_rating_configuration
    @gs_rating_configuration = gs_rating_configuration
    @prek_rating_configuration = prek_rating_configuration
  end

  def self.configuration_for_school(state)
    city_rating_configuration, state_rating_configuration, gs_rating_configuration, prek_rating_configuration = nil
    rating_configuration = SchoolProfileConfiguration.for_state(state)


    rating_configuration.each do |config|
      if config.configuration_key == 'city_rating'
        city_rating_configuration = JSON.parse(config.value)
      elsif config.configuration_key == 'state_rating'
        state_rating_configuration = JSON.parse(config.value)
      elsif config.configuration_key == 'gs_rating'
        gs_rating_configuration = JSON.parse(config.value)
      elsif config.configuration_key == 'preK_rating'
        prek_rating_configuration = JSON.parse(config.value)
      end
    end
    RatingsConfiguration.new(city_rating_configuration, state_rating_configuration, gs_rating_configuration, prek_rating_configuration)
  end

  def gs_rating_data_type_ids
    @gs_rating_configuration.blank? ? [] : @gs_rating_configuration["rating_breakdowns"].values.map{|r| r["data_type_id"]}
  end

  def state_rating_data_type_ids
    data_type_ids = []
    if @state_rating_configuration.present?
      data_type_ids = Array(@state_rating_configuration["overall"]["data_type_id"])
      if @state_rating_configuration["rating_breakdowns"].present?
        data_type_ids += @state_rating_configuration["rating_breakdowns"].values.map{|r|r["data_type_id"]}
      end
    end
    data_type_ids
  end

  def city_rating_data_type_ids
    data_type_ids = []
    if @city_rating_configuration.present?
      data_type_ids = Array(@city_rating_configuration["overall"]["data_type_id"])
      if @city_rating_configuration["rating_breakdowns"].present?
        data_type_ids += @city_rating_configuration["rating_breakdowns"].values.map{|r|r["data_type_id"]}
      end
    end
    data_type_ids
  end

  def prek_rating_data_type_ids
    @prek_rating_configuration.blank? ? [] : Array(@prek_rating_configuration["star_rating"]["data_type_id"])
  end

end