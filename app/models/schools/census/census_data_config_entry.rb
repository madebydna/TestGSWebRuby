class CensusDataConfigEntry < ActiveRecord::Base
  self.table_name = 'census_data_config_entry'
  include StateSharding
  self.inheritance_column = nil

  def self.for_data_set(shard, census_data_set)
    configs = data_type_to_configs(shard)[census_data_set.data_type_id] || []
    configs = configs.clone
    configs.select! do |config|

      (
        # If the group is configured in the config table and all its breakdowns also configured in the config table.
        # Example:- Student Ethnicity  (group_id=6)
        (config.breakdown_id.present? && config.breakdown_id == census_data_set.breakdown_id) ||
        # If the group is configured in the config table, but all its breakdowns are in the census_data_set table.
        # Example:- Home Language Learners  (group_id=10)
        (config.breakdown_id.blank? && census_data_set.breakdown_id && configs.size == 1) ||
        # If the group is configured in the config table and all its breakdowns also configured in the config table.
        # However "All students"= breakdownId=null. Hence we need this matcher.
        (census_data_set.breakdown_id.nil?)
      ) &&
      ( config.grade.blank? || config.grade == census_data_set.grade )

    end
  end

  def self.data_type_to_configs(shard)
    Rails.cache.fetch("census_data_config_entry/data_type_to_configs/#{shard}", expires_in: 5.minutes) do
      configs = CensusDataConfigEntry.on_db(shard).all.group_by(&:data_type_id)
    end
  end

end
