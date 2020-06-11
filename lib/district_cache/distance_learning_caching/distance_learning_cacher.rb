# frozen_string_literal: true
class DistanceLearningCacher < DistrictCacher
  CACHE_KEY = 'crpe'

  def self.listens_to?(data_type)
    data_type == :crpe
  end

  def build_hash_for_cache
    responses = CRPEData.by_district(district).active
    return unless responses.present?

    responses.each_with_object({}) do |response, result|
      result[response.data_type] = {}.tap do |hash|
        hash['data_type'] = response.data_type
        hash['value'] = response.value
        hash['date_valid'] = response.date_valid.to_date
        hash['source'] = response.source
      end
    end
  end

end