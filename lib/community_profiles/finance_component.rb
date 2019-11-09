module CommunityProfiles
  class FinanceComponent
    include CommunityProfiles::FinanceConfig

    def initialize(data_hash)
      @data_hash = data_hash
    end

    def data_values
      return [] unless @data_hash.present?
      @data_hash.map do |data_hash|
        accessor = CHAR_CACHE_ACCESSORS.find {|h| h[:key] == data_hash[:data_type]}
        next if accessor.nil?
        {}.tap do |hash|
          hash['data_type'] = data_hash[:data_type]
          hash['name'] = I18n.t(data_hash[:data_type], scope: 'lib.finance.data_types')
          hash['district_value'] = SchoolProfiles::DataPoint.new(data_hash[:district_value]).apply_formatting(*accessor[:formatting]).format
          hash['state_value'] =  SchoolProfiles::DataPoint.new(data_hash[:state_value]).apply_formatting(*accessor[:formatting]).format
          hash['year'] = Date.parse(data_hash[:source_date_valid]).year
          hash['source'] = {
            name: I18n.t(data_hash[:data_type], scope: 'lib.finance.data_types'),
            description: I18n.t(data_hash[:data_type], scope: 'lib.finance.tool_tips'),
            source_and_year: "#{data_hash[:source_name]}, #{Date.parse(data_hash[:source_date_valid]).year}"
          }
          hash['type'] = accessor[:type]
          hash['tooltip'] = I18n.t(data_hash[:data_type], scope: 'lib.finance.tool_tips')
          hash['color'] = accessor[:color] if accessor[:color]
        end
      end.compact
    end
  end
end