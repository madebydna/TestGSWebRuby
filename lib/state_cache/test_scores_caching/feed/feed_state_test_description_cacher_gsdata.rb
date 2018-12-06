# frozen_string_literal: true

class TestScoresCaching::Feed::FeedStateTestDescriptionCacherGsdata < TestScoresCaching::StateTestScoresCacherGsdata
  CACHE_KEY = 'feed_test_description_gsdata'

  def query_results
    @query_results ||=
      begin
        test_data_type_ids = unique_data_type_ids
        dti_state = test_data_type_ids.map do |dti|
          state_result = state_for_data_type_id(dti)
          {data_type_id: dti, state: state_result&.first}
        end
        dti_state.select{|arr| arr[:state].upcase == state.upcase}
      end
  end

  def state_for_data_type_id(dti)
    DataValue.where(data_type_id: dti).limit(1).map(&:state)
  end

  def unique_data_type_ids
    Load.with_data_types.with_data_type_tags('state_test')
        .with_configuration('feeds')
        .map(&:data_type_id)
        .uniq
  end

  def build_hash_for_cache
    query_results.map do |obj|
      hash = {}
      loads_data_info = Load.where(data_type_id: obj[:data_type_id]).order(date_valid: :desc)&.first
      hash['most-recent-year'] = loads_data_info&.date_valid&.year
      hash['description'] = loads_data_info&.description
      data_type_info = loads_data_info&.data_type
      hash['test-id'] = data_type_info&.id
      hash['test-name'] = data_type_info&.name
      hash['test-abbrv'] = data_type_info&.short_name
      data_value_obj = DataValue.where("load_id = ? && proficiency_band_id > 1", loads_data_info.id).limit(1).reorder(nil)
      hash['scale'] = ''
      if data_value_obj&.first
        hash['scale'] = scale(data_value_obj.first[:proficiency_band_id])
      end
      hash
    end
  end

  def scale(proficiency_band_id)
    pb_obj = ProficiencyBand.where(id: proficiency_band_id)
    group_id = pb_obj.first[:group_id] if pb_obj&.first
    group_pbs = ProficiencyBand.where(group_id: group_id, composite_of_pro_null: 1).order('group_order ASC')
    scale_keys = group_pbs.map(&:name)
    scale = scale_keys.size < 3 ? scale_keys.join(' or ') : scale_keys.join(', ')
    "% #{scale}" if scale
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

end