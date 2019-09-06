# frozen_string_literal: true

class TestScoresCaching::Feed::FeedStateTestDescriptionCacherGsdata < TestScoresCaching::StateTestScoresCacherGsdata
  CACHE_KEY = 'feed_test_description_gsdata'

  def query_results
    @query_results ||=
      begin
        Omni::DataSet.select("data_sets.id, data_sets.data_type_id, data_sets.date_valid, data_sets.description, data_types.id as test_id, data_types.name, data_types.short_name")
          .feeds_by_state(state).filter_by_data_type_tag('state_test')
          .group_by(&:data_type_id).map do |id, ds_data|
            ds_data.max_by(&:date_valid)
          end
      end
  end

  def build_hash_for_cache
    query_results.map do |ds|
      hash = {}
      hash['most-recent-year'] = ds.date_valid.year
      hash['description'] = ds.description
      hash['test-id'] = ds.test_id
      hash['test-name'] = ds.name
      hash['test-abbrv'] = ds.short_name
      test_data_value_obj = ds.test_data_values.where("proficiency_band_id > 1").reorder(false).first
      hash['scale'] = scale(test_data_value_obj&.proficiency_band)
      hash
    end
  end

  def scale(proficiency_band)
    return '' unless proficiency_band.present?
    group_pbs = Omni::ProficiencyBand.where(group_id: proficiency_band.group_id, composite_of_pro_null: 1).order('group_order ASC')
    scale_keys = group_pbs.map(&:name)
    scale = scale_keys.size < 3 ? scale_keys.join(' or ') : scale_keys.join(', ')
    scale.present? ? "% #{scale}" : ''
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

end