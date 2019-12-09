# frozen_string_literal: true

module StateCachedStateAttributeMethods
  def state_attributes
    @_state_attributes ||= cache_data.fetch('state_attributes', {})
  end

  def fetch_state_attribute(key_name)
    case key_name
    when 'growth_type'
      state_attributes.dig('growth_type')
    when 'hs_enabled_growth_rating'
      state_attributes.dig('hs_enabled_growth_rating')
    when 'summary_rating_type'
      state_attributes.dig('summary_rating_type')
    end
  end
end
