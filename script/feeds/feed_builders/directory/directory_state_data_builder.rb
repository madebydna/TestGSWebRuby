module Feeds
  class DirectoryStateDataBuilder
    include Feeds::FeedConstants
    include States

    DIRECTORY_STATE_KEYS = %w(universal_id state_name state census_info)

    def self.build_data(state)
      @state = state.upcase
      @universal_id = UniversalId.calculate_universal_id(@state)

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
      single_data_object('state-name',States.state_name(@state).capitalize)
    end

    def self.state
      single_data_object('state',@state)
    end

    def self.census_info
      characteristics_hash = {} # need to build a pretty hash to feed into the monster
      char_data = CharacteristicsDataBuilder.characteristics_format(characteristics_hash, @universal_id)
      single_data_object('census-info', char_data) if char_data.compact.present?
    end

    def self.single_data_object(name, value, attrs=nil)
      SingleDataObject.new(name, value, attrs)
    end

  end
end