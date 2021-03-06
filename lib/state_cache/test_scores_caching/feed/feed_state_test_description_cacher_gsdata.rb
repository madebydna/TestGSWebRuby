# frozen_string_literal: true

class TestScoresCaching::Feed::FeedStateTestDescriptionCacherGsdata < TestScoresCaching::StateTestScoresCacherGsdata
  CACHE_KEY = 'feed_test_description_gsdata'


  # first get all the load ids for the state
  # second get all the state_test results for that state
  # third filter load ids to the most recent year for each data_type_id
  def query_results
    @query_results ||=
      begin
        load_ids_for_state = DataValue.filter_query(state).pluck(:load_id).uniq
        state_test_load_ids = Load.data_type_tags_to_loads(%w(state_test), %w(feeds), load_ids_for_state).map(&:id).uniq
        filter_to_most_recent_load_id_by_data_type_id(state_test_load_ids)
      end
  end

  # added the last line to maintain state filter - reversed process to first get state ids then get most recent.
  def filter_to_most_recent_load_id_by_data_type_id(ids)
    Load.find_by_sql("select loads1.data_type_id, loads1.id, loads1.date_valid from gsdata.loads loads1 INNER JOIN
                      (select loads2.data_type_id, MAX(loads2.date_valid) as dv from gsdata.loads loads2
                        where id in ( #{ids.join(',')})
                        group by loads2.data_type_id) most_recent_load
                      on loads1.data_type_id = most_recent_load.data_type_id and loads1.date_valid = most_recent_load.dv
                      and loads1.id in ( #{ids.join(',')} )")
  end

  def build_hash_for_cache
    query_results.map do |obj|
      hash = {}
      loads_data_info = Load.where(id: obj[:id]).order(date_valid: :desc)&.first
      hash['most-recent-year'] = loads_data_info&.date_valid&.year
      hash['description'] = loads_data_info&.description
      data_type_info = loads_data_info&.data_type
      hash['test-id'] = data_type_info&.id
      hash['test-name'] = data_type_info&.name
      hash['test-abbrv'] = data_type_info&.short_name
      data_value_obj = DataValue.where("load_id = ? && proficiency_band_id > 1", loads_data_info&.id).limit(1).reorder(nil)
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