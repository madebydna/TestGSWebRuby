module JsonifiedAttributeConcerns
  extend ActiveSupport::Concern

  included do
    cattr_accessor :jsonified_attributes

    # Species a list of attributes that should be stored as JSON within an attribute on this model
    #
    # List of attributes is required
    # Last argument provided should be a hash
    # Name of json attribute to use is required
    # Type is optional and defaults to :string
    # Valid types: :integer | :string
    #
    # Example usages:
    #
    # jsonified_attribute :url, :title, :description,   json_attribute: :json_blob, type: :string
    # jsonified_attribute :rating, :count,              json_attribute: :json_blob, type: :integer
    #
    def self.jsonified_attribute(*args)
      named_arguments = args.extract_options!
      json_attribute = named_arguments[:json_attribute]
      raise ArgumentError, ':json_attribute option must be provided' unless json_attribute
      type = named_arguments[:type] || :string
      attributes = args

      # Call ActiveRecord's attr_accessible to make all the attributes appear as real attributes to rails_admin
      attr_accessible *attributes

      # Define getters and settes for each attribute
      attributes.each do |attribute|
        # Setter should set the attribute and update the JSON blob
        define_method("#{attribute}=") do |value|
          value = value.to_i if value.present? && type == :integer
          instance_variable_set("@#{attribute}", value)
          write_json_attribute(json_attribute)
        end

        # Getter should parse the JSON blob to get the value
        define_method(attribute) do
          read_json_attribute(json_attribute).try(:fetch, attribute.to_s, nil)
        end
      end

      # Keep all the attributes in an array on the class, so that this jsonified_attributes can be called multiple times
      self.jsonified_attributes ||= []
      self.jsonified_attributes += attributes
    end
  end

  def write_json_attribute(json_attribute)
    hash = jsonified_attributes.each_with_object({}) do |attribute, h|
      value = instance_variable_get("@#{attribute}")
      if value.present?
        h[attribute] = value
      end
    end
    json = hash.present? ? hash.to_json : nil
    write_attribute(json_attribute, json)
  end

  def read_json_attribute(json_attribute)
    json = read_attribute(json_attribute)
    if json.present?
      begin    JSON.parse(json) rescue {}
      rescue JSON::ParserError => e
        Rails.logger.debug "ERROR: parsing JSON for ID on table  #{self.id} \n" +
                               "Exception message: #{e.message}"
      end
    else
      {}
    end
  end

end