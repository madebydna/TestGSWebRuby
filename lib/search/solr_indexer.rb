# frozen_string_literal: true

module Search
  class SolrIndexer
    attr_reader :client

    module Types
      STRING = :string
      TEXT = :text_ss
      INTEGER = :int
      LAT_LON = :latLonPointSpatialField
      FLOAT = :float
      TEXT_LOCATION_SYNONYMS = :text_location_synonyms
      DATE = :date
    end

    def self.make_field(name, value, type: nil, stored: false, indexed: true)
      type = type || value_to_schema_type(value)
      if name == :id || name == :type # "special" fields
        field_name = name
      else
        field_name = solr_field_name(name, type)
      end

      {
        name: field_name,
        type: type,
        stored: stored,
        indexed: indexed,
        multiValued: value.is_a?(Array),
      }
    end

    def self.value_to_schema_type(value)
      value = value.first if value.is_a?(Array)
      case value
      when String
        Types::STRING
      when Integer
        Types::INTEGER
      when Float
        Types::FLOAT
      else
        raise "Unknown type: #{value.class}. Could not map to Solr Schema field type"
      end
    end

    def self.solr_field_name(name, type)
      "#{name}_#{field_type_suffix(type)}"
    end

    def self.remove_type_suffix(name, type)
      suffix = field_type_suffix(type)
      name.sub(/#{name}$/, '')
    end

    def self.field_type_suffix(type)
      case type.to_sym
      when Types::STRING
        "s"
      when Types::TEXT
        "text"
      when Types::TEXT_LOCATION_SYNONYMS
        "text"
      when Types::INTEGER
        "i"
      when Types::FLOAT
        "f"
      when Types::LAT_LON
        "ll"
      when Types::DATE
        "d"
      else
        raise "Unknown type: #{type}. Could not map to suffix"
      end
    end

    def self.with_rsolr_client(url)
      new(solr_client: RSolr.connect(url: url))
    end

    #######################################################################################33

    def initialize(solr_client:)
      @client = solr_client
    end

    def index(indexables, create_fields: true)
      raise ArgumentError.new("Must provide indexable items, given nil") unless indexables

      indexables.each do |indexable|
        next unless indexable.any_fields_added?
        if create_fields
          indexable.field_values.each { |f, v| add_field(f) unless field_exists?(f) }
        end
        solr_field_values = indexable.field_values.each_with_object({}) do |(f, v), hash|
          hash[f[:name]] = v
        end
        client.add(solr_field_values)
      end
    end

    def delete_all_by_type(indexable_class)
      unless indexable_class && indexable_class.respond_to?(:type)
        raise ArgumentError.new("Must provide class that is indexable")
      end
      client.delete_by_query("type:#{indexable_class.type}")
    end

    def commit
      client.commit
    end

    def optimize
      client.optimize
    end

    private

    def add_field(field)
      client.post(
        "/solr/main/schema",
        headers: {
          "Content-Type" => "application/json",
        },
        data: {
          "add-field" => field,
        }.to_json,
      )
      @_solr_fields = nil
    end

    def solr_fields
      @_solr_fields ||= client.get("/solr/main/schema/fields")["fields"]
    end

    def solr_field_names
      solr_fields.map { |h| h["name"] }
    end

    def field_exists?(field)
      solr_field_names.include?(field[:name].to_s)
    end
  end
end
