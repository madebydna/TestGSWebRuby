# frozen_string_literal: true

module StateCachedRatingMethods
  def ratings
    @_ratings ||= cache_data.fetch('ratings', {})
  end
end
