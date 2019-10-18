module CommunityProfiles
  class MainStaffData

    attr_reader :formatters, :info
    def initialize(info, formatters)
      @info = info
      @formatters = formatters
    end

    def to_h
      {
        district_value: to_value(info.district_value),
        state_value: to_value(info.state_value),
        year: Date.parse(info.source_date_valid).year,
        source: info.source_name
      }
    end

    private

    def to_value(val)
      SchoolProfiles::DataPoint.new(val, *formatters).format
    end
  end
end