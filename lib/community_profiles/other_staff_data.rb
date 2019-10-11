module CommunityProfiles
  class OtherStaffData
    attr_reader :formatters, :full_time_value, :part_time_value

    def initialize(full_time_value, part_time_value, formatters)
      @full_time_value = full_time_value
      @part_time_value = part_time_value
      @formatters = formatters
    end

    def to_h
      [*full_time_hash, *part_time_hash].to_h
    end

    private

    def full_time_hash
      full_time_value.present? ? {
        full_time_district_value: to_value(full_time_value.district_value),
        full_time_state_value:  to_value(full_time_value.state_value),
        year: Date.parse(full_time_value.source_date_valid).year,
        source: full_time_value.source_name
      } : {}
    end

    def part_time_hash
      part_time_value.present? ? {
        part_time_district_value: to_value(part_time_value.district_value),
        part_time_state_value: to_value(part_time_value.state_value)
      } : {}
    end

    def to_value(val)
      SchoolProfiles::DataPoint.new(val, *formatters).format
    end
  end
end