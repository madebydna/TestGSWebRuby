class ExactTarget
  class MobileContactsHashService
    attr_reader :attributes, :phone_number

    def initialize(phone_number, attributes = nil)
      @phone_number = phone_number
      @attributes = attributes || default_attributes
    end

    def default_attributes
      {Locale: "US", Status: 1, Source: 'API' }
    end

    def self.create(phone_number, attributes = nil)
      new(phone_number, attributes).create
    end

    def create
      {
        "contactKey"=> phone_number,
        "attributeSets"=>[attribute_sets_hash]
      }
    end

    def attribute_sets_hash
      {
        "name"=> "MobileConnect Demographics",
        "items" => [{
          "values"=> attributes_array
        }]
      }
    end

    def required_mobile_number_attribute
      {
        "name"=> "Mobile Number",
        "value"=> phone_number
      }
    end

    def attributes_array
      attributes.map do |name, value|
        value = MobileDemographicsValueMapper.map(name, value)
        {"name" => name.to_s, "value"=> value}
      end.unshift(required_mobile_number_attribute)
    end

    class MobileDemographicsValueMapper

      attr_reader :name, :value

      def initialize(name, value)
        @name = name.to_s.downcase.to_sym
        @value = value
      end

      def self.map(name,value)
        new(name, value).map
      end

      def map
        if respond_to?(name)
          return send(name, value) || value
        else
          value
        end
      end

      def status(value)
        status_map = {'Active' => 1, 'Inactive' => 2}
        status_map[value]
      end

      def source(value)
        source_map[value.to_s]
      end

      def source_map
        @_mobile_connect_source_map ||= (
          sources = ['Web Collect', 'API', 'FTAT', 'Import', 'Move Copy', 'Manually Added', 'Sales Force', 'Segmentation', 'Generic Extension', 'Custom Object', 'Facebook API', 'Smart Capture', 'Mobile Opt-in']
          sources.each_with_object({}).with_index do |(v, hash), index|
            hash[v] = index + 1
          end
        )
      end
    end
  end
end
 
