# frozen_string_literal: trues

module Components
  class GrowthDataOverall < Component
    def normalized_values
      cr_data = cache_data_reader.decorated_school.ratings_by_type[cache_data_reader.growth_type]
      cr_data ? cr_data.having_most_recent_date.map {|h| normalize_rating_value(h)} : []
    end

    def normalize_rating_value(value)
      {}.tap do |h|
        h[:breakdown] = value.breakdown
        h[:score] = value.school_value
        h[:state_average] = value.state_value
        h[:percentage] = breakdown_percentage(value) if breakdown_percentage(value)
      end
    end

    def breakdown_percentage(value)
      value_to_s(ethnicities_to_percentages[value.breakdown])
    end
  end
end
