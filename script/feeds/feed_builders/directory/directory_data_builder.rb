module Feeds
  class DirectoryDataBuilder
    include Feeds::FeedConstants

    def self.build_data(hash, state, model)
      @value_key = model.downcase + '_value'
      @model = model
      @state = state
      keys = FeedConstants.const_get("DIRECTORY_FEED_#{model.upcase}_CACHE_KEYS")
      @directory_hash = hash[keys[0]]
      @characteristics_hash = hash[keys[1]]
      id = cache_value(@directory_hash, 'id')
      @universal_id = UniversalId.calculate_universal_id(state, FeedConstants.const_get("ENTITY_TYPE_#{model.upcase}"), id)

      arr = []

      DIRECTORY_FEED_FORCE_ORDER.each do | key |
        if DIRECTORY_KEYS_SPECIAL.include? key
          sdo = send(key)
          arr << sdo if sdo
        else
          value = cache_value(@directory_hash,key)
          key_string = key.to_s.gsub('_', '-').downcase
          # remove particular keys from District - so if District and key in Exempt list don't show it
          if model != 'District' || !(DIRECTORY_DISTRICT_EXEMPT.include? key)
            # if the key is required or it has a value add it to array to show
            arr << single_data_object(key_string, value) if DIRECTORY_KEYS_REQUIRED.include? key || value.present?
          end
        end
      end

      arr.flatten
    end

    # //////////////////////////////  DIRECTORY_KEYS_SPECIAL -- REQUIRED ///////////////////////////////////////////////////////////////

    def self.universal_id
      single_data_object('universal-id',@universal_id)
    end

    def self.home_page_url
      single_data_object('website',cache_value(@directory_hash,'home_page_url'))
    end

    def self.zipcode
      single_data_object('zip',cache_value(@directory_hash,'zipcode'))
    end

    def self.url
      url = cache_value(@directory_hash,'url') || 'https://www.greatschools.org/'
      arr = []
      if @model == 'School'
        url_reviews = url+'#Reviews'
        url_test_scores = url+'#Test_scores'
        url_students = url+'#Students'
        arr << single_data_object('url', url, {'type'=>'School Overview', 'universal-id' => @universal_id})
        arr << single_data_object('url', url, {'type'=>'Ratings', 'universal-id' => @universal_id})
        arr << single_data_object('url', url_students, {'type'=>'Student/Teacher', 'universal-id' => @universal_id})
        arr << single_data_object('url', url_reviews, {'type'=>'Parent Reviews', 'universal-id' => @universal_id})
        arr << single_data_object('url', url_test_scores, {'type'=>'Test Scores', 'universal-id' => @universal_id})
      else
        arr << single_data_object('url', url, {'type'=>'District Overview', 'universal-id' => @universal_id})
      end
      arr
    end

    # //////////////////////////////  DIRECTORY_KEYS_SPECIAL -- END REQUIRED ///////////////////////////////////////////////////////////////


    # //////////////////////////////  DIRECTORY_KEYS_SPECIAL -- NOT REQUIRED ///////////////////////////////////////////////////////////////

    def self.universal_district_id
      district_id = cache_value(@directory_hash,'district_id')
      uni_district_id = UniversalId.calculate_universal_id(@state, ENTITY_TYPE_DISTRICT, district_id)
      single_data_object('universal-district-id',uni_district_id) if district_id && uni_district_id && @model == 'School'
    end

    def self.state_id
      state = cache_value(@directory_hash,'state')
      single_data_object('state-id',state_fips[state.upcase]) if state
    end

    def self.census_info
      char_data = CharacteristicsDataBuilder.characteristics_format(@characteristics_hash, @universal_id, @model)
      single_data_object('census-info', char_data) if char_data && char_data.compact.present?
    end

    # //////////////////////////////  DIRECTORY_KEYS_SPECIAL -- END NOT REQUIRED ///////////////////////////////////////////////////////////////

    def self.cache_value(data_set, name)
      sv = cache_object(data_set, name)
      sv[@value_key] if sv
    end

    def self.cache_object(data_set, name)
      data_set[name].find{|obj| obj[@value_key]} if data_set[name]
    end

    def self.single_data_object(name, value, attrs=nil)
      SingleDataObject.new(name, value, attrs)
    end

  end
end