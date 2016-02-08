class DetailsOverviewDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  SCHOOL_CACHE_KEYS = [ 'characteristics', 'esp_responses' ]

  attr_accessor :category, :config, :data

  def data_for_category(category)
    begin
      self.category = category
      self.config = category.parsed_json_config
      raw_cache_data = all_school_cache_data_raw
      CombineCharacteristicsAndEspResponsesData.new(category, raw_cache_data).run
    rescue  => error
      GSLogger.error('MISC', error, message: "Details overview data reader failed to get data for category: #{category}")
      {}
    end
  end

  protected

  def all_school_cache_data_raw
    @_all_school_cache_data_raw ||= (
      school_cache_results = SchoolCache.cached_results_for(school, self.class::SCHOOL_CACHE_KEYS).school_data_hash.values.first
    )
  end

  class CombineCharacteristicsAndEspResponsesData
    def initialize(category, raw_cache_data)
      @raw_cache_data = raw_cache_data
      @category = category
      @esp_raw_cache_data = @raw_cache_data["esp_responses"]
      @characteristics_raw_cache_data = @raw_cache_data["characteristics"]
      @esp_cache_data = get_esp_response_cache_data
      @characteristics_cache_data = get_characteristics_cache_data
      @key_map = build_key_map
    end

    def run
      esp_data = build_esp_data
      characterstics_data =  build_characteristics_data
      esp_data.merge(characterstics_data)
    end

    def get_desired_esp_keys
      @category.category_data.select { |d| d.key_type == "esp_response" }.map(&:response_key)
    end

    def get_esp_response_cache_data
      get_desired_esp_keys.each_with_object({}) do |key, h|
        if @esp_raw_cache_data && @esp_raw_cache_data[key]
          h[key] = @esp_raw_cache_data[key]
        end
      end
    end

    def get_desired_characteristics_keys
      @category.category_data.select { |d| d.key_type == "census_data" }.map(&:response_key)
    end

    def get_characteristics_cache_data
      get_desired_characteristics_keys.each_with_object({}) do |key, h|
        if @characteristics_raw_cache_data && @characteristics_raw_cache_data[key]
          h[key] = @characteristics_raw_cache_data[key] 
        end
      end
    end

    def build_esp_data
      @esp_cache_data.each_with_object({}) do |esp_array, results_hash|
        response_key = esp_array.first
        response_values_array = esp_array.last.keys
        value = EspResponseValueParser.new(response_key, response_values_array).parse
        key = @key_map[response_key]
        results_hash[key] = value
      end
    end

    def build_key_map
      @category.category_data.each_with_object({}){ |cd, h| h[cd.response_key] = cd.label(false) }
    end

    def build_characteristics_data
      @characteristics_cache_data.each_with_object({}) do |(k,v), results_hash|
        response_key = k
        characterstics_array_hash = v
        value = CharacteristicsValueParser.new(characterstics_array_hash).parse
        key = @key_map[response_key]
        results_hash[key] = value
      end
    end
  end

  class EspResponseValueParser
    def initialize(esp_response_key, response_values_array)
      @response_values_array = response_values_array
      @esp_response_key = esp_response_key
    end

    def parse
      @response_values_array.map { |response_value| value(response_value) }
    end

    def value(response_value)
      response_value_map[[@esp_response_key,response_value]] || response_value
    end

    def response_value_map
      @_response_value_map ||=(
        ResponseValue.lookup_table
      )
    end
  end

  class CharacteristicsValueParser
    def initialize(hash)
      @characteristics_hash = hash
    end

    def parse
      @characteristics_hash.each_with_object({}) do |(chars_hash), result_hash|
      next unless chars_hash["school_value"]
      result_hash[I18n.db_t(chars_hash["breakdown"])] = chars_hash["school_value"]
      end
    end
  end

end


