class DetailsOverviewDataReader < SchoolProfileDataReader
  include CachedCategoryDataConcerns

  SCHOOL_CACHE_KEYS = [ 'characteristics', 'esp_responses' ]

  attr_accessor :category, :config, :data

  def data_for_category(category)
    self.category = category
    self.config = category.parsed_json_config
    get_data!
    transform_data_keys!
    CombineCharacteristicsAndEspResponsesData.new(data).run
  rescue  => error
    GSLogger.error('MISC', error, message: "Details overview data reader failed to get data for category: #{category}")
    {} 
  end

  protected

  def get_data!
    self.data = cached_data_for_category
  end

  class CombineCharacteristicsAndEspResponsesData
    def initialize(data)
      @data = data
    end

    def run
      @data.each_with_object({}) do |(key, value), hash|
        begin
          hash[get_key(key)] = EspAndCharacteristicsValueParserFactory.new(value).build.value
        rescue Error::InvalidDataReaderFormat =>error
          GSLogger.error('MISC', error, message: "Details overview data reader failed to parse key:#{key} value: #{value}")
        end
      end
    end

    def get_key(key)
      key.first if key.is_a?(Array) && key.first.is_a?(String)
    end
  end

  class EspAndCharacteristicsValueParserFactory
    def initialize(value)
      @value = value
    end

    def characteristics
      CharacteristicsValueParser.new(@value)
    end

    def esp
      EspResponseValueParser.new(@value)
    end

    def unknown
      raise Error::InvalidDataReaderFormat,
        'Invalid data for details overview data reader'
    end

    def build
      type =  DataTypeDetector.new(@value).data_type
      self.send(type)
    end
  end

  class EspResponseValueParser
    def initialize(hash)
      @esp_hash = hash
    end

    def value
      @esp_hash.first.keys.map do |value|
        I18n.db_t(value.to_s.capitalize.gsub('_',' '), default: value.to_s)
      end
    end
  end

  class CharacteristicsValueParser
    def initialize(hash)
      @characteristics_hash = hash
    end

    def value
      @characteristics_hash.each_with_object({}) do |(chars_hash), result_hash|
      next unless chars_hash[:school_value]
      result_hash[I18n.db_t(chars_hash[:breakdown])] = chars_hash[:school_value]
      end
    end
  end

  class DataTypeDetector

    REQUIRED_CHARACTERISTICS_KEYS = [:breakdown]
    REQUIRED_ESP_KEYS = ["member_id", "source"]
    VALID_ESP_DATA_SOURCES= ["usp", "osp", "datateam"]

    def initialize(value)
      @value = value
    end

    def data_type
      return :unknown unless @value.is_a?(Array)
      return :characteristics if characteristics?
      return :esp if esp?
      return :unknown
    end

    private

    def characteristics?
      @value.all? { |hash| is_valid_characteristics_data_hash?(hash) }
    end

    def is_valid_characteristics_data_hash?(hash)
      REQUIRED_CHARACTERISTICS_KEYS.all? { |key| hash.has_key?(key) }
    end

    def esp?
      @value.count == 1 && is_valid_esp_data_hash?(@value.first)
    end

    def is_valid_esp_data_hash?(hash)
      hash.is_a?(Hash) && 
        hash.values.all? do |hash|
        is_valid_esp_data_hash_value?(hash)
      end
    end

    def is_valid_esp_data_hash_value?(esp_value_hash)
      esp_value_hash.is_a?(Hash) &&
        REQUIRED_ESP_KEYS.all? { |key| esp_value_hash.has_key?(key) } &&
          valid_esp_data_source?(esp_value_hash['source'])
    end

    def valid_esp_data_source?(source)
      VALID_ESP_DATA_SOURCES.include?(source)
    end
  end

end


