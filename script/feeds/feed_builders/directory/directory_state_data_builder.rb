module Feeds
  class DirectoryStateDataBuilder
    include Feeds::FeedConstants
    include States

    DIRECTORY_STATE_KEYS = %w(universal_id state_name state census_info)

    CACHE_KEY_CHARACTERISTICS = 'metrics'
    CACHE_KEY_GSDATA = 'gsdata'

    def self.build_data(state)
      @state = state.upcase
      @universal_id = UniversalId.calculate_universal_id(@state).to_i.to_s

      arr = []
      DIRECTORY_STATE_KEYS.each do | key |
        sdo = send(key)
        arr << sdo if sdo
      end
      arr.flatten
    end

    def self.universal_id
      single_data_object('universal-id',@universal_id)
    end

    def self.state_name
      single_data_object('state-name',States.labels_hash[@state.downcase])
    end

    def self.state
      single_data_object('state',@state)
    end

    def self.census_info
      characteristics_hash = state_data # need to build a pretty hash to feed into the monster
      char_data = CharacteristicsDataBuilder.characteristics_format(characteristics_hash, @universal_id, 'state')
      single_data_object('census-info', char_data) if char_data.try(:compact).present?
    end

    def self.single_data_object(name, value, attrs=nil)
      SingleDataObject.new(name, value, attrs)
    end

    def self.state_data
      state_gsdata = gsdata || {}
      state_characteristics_data = characteristics_data || {}
      if state_gsdata
        state_gsdata.merge(state_characteristics_data)
      else
        state_characteristics_data
      end
    end

    def self.characteristics_data
      state_characteristics_data = StateCache.for_state(CACHE_KEY_CHARACTERISTICS, @state)
      state_characteristics_data&.cache_data
    end

    def self.gsdata
      state_gsdata = StateCache.for_state(CACHE_KEY_GSDATA, @state)
      state_gsdata&.cache_data
    end

  end
end
