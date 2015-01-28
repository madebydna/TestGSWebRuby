class RatingsConfiguration < Hashie::Mash

  def self.configuration_for_school(state)
    school_profile_configuration = SchoolProfileConfiguration.for_state(state)

    params = {
      city_rating: nil,
      state_rating: nil,
      preschool_rating: nil,
      gs_rating: nil,
      pcsb_rating: nil
    }

    school_profile_configuration.each do |config|
      hash = config.present? ? JSON.parse(config.value) : {}
      params[config.configuration_key.downcase] = hash
    end

    return RatingsConfiguration.new(params)
  end

end