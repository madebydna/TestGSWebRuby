module Feeds
  class DirectoryDataBuilder
    include Feeds::FeedConstants

    def self.build_data(hash, state, model)
      @value_key = model.downcase + '_value'
      @model = model
      @state = state

      # Get some constants based on school or district
      cache_keys          = FeedConstants.const_get("DIRECTORY_FEED_#{model.upcase}_CACHE_KEYS")
      data_keys_all       = FeedConstants.const_get("DIRECTORY_#{model.upcase}_KEY_ORDER")
      data_keys_special   = FeedConstants.const_get("DIRECTORY_#{model.upcase}_KEYS_SPECIAL")
      data_keys_required  = FeedConstants.const_get("DIRECTORY_#{model.upcase}_KEYS_REQUIRED")

      @directory_hash = hash[cache_keys[0]]
      @metrics_hash = metrics_hash_build(hash, cache_keys)
      id = cache_value(@directory_hash, 'id')
      @universal_id = UniversalId.calculate_universal_id(state, FeedConstants.const_get("ENTITY_TYPE_#{model.upcase}"), id)

      arr = []

      data_keys_all.each do | key |
        if data_keys_special.include? key
          sdo = send(key)
          arr << sdo if sdo
        else
          value = cache_value(@directory_hash,key)
          key_string = key.to_s.gsub('_', '-').downcase
            # if the key is required or it has a value add it to array to show
          arr << single_data_object(key_string, value) if ((data_keys_required.include? key) || value.present?)

        end
      end

      arr.flatten
    end

    def self.metrics_hash_build(hash, cache_keys)
      state_gsdata = hash[cache_keys[2]] || {}
      state_metrics_data = hash[cache_keys[1]] || {}
      if state_gsdata && state_metrics_data
        state_gsdata.merge(state_metrics_data)
      else
        state_metrics_data
      end
    end

    # //////////////////////////////  DIRECTORY_KEYS_SPECIAL -- REQUIRED ///////////////////////////////////////////////////////////////

    def self.universal_id
      single_data_object('universal-id',@universal_id)
    end

    def self.home_page_url
      single_data_object('web-site',cache_value(@directory_hash,'home_page_url'))
    end

    def self.level
      level_value = cache_value(@directory_hash,'level')
      if level_value == 'Ungraded'
        level_value =  'n/a'
      elsif level_value.present?
        level_value.slice! ' & Ungraded'
      end
      single_data_object('level',level_value)
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

    def self.metrics_info
      metrics_data = MetricsDataBuilder.metrics_format(@metrics_hash, @universal_id, @model) if @metrics_hash.present?
      single_data_object('census-info', metrics_data) if metrics_data && metrics_data.compact.present?
    end

    # //////////////////////////////  DIRECTORY_KEYS_SPECIAL -- END NOT REQUIRED ///////////////////////////////////////////////////////////////

    def self.cache_value(data_set, name)
      sv = cache_object(data_set, name)
      sv[@value_key] if sv
    end

    def self.cache_object(data_set, name)
      data_set[name].find{|obj| obj[@value_key]} if data_set && data_set[name]
    end

    def self.single_data_object(name, value, attrs=nil)
      SingleDataObject.new(name, value, attrs)
    end

  end
end
