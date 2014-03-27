class SchoolProfileConfiguration < ActiveRecord::Base
  attr_accessible :configuration_key, :state, :value

  self.table_name = 'school_profile_configurations'
  db_magic :connection => :profile_config
  attr_accessible :state, :quay, :value

  def self.for_state(state = nil)
    all_mappings = Rails.cache.fetch('school_profile_configuration/all', expires_in: 5.minutes) do
      self.all
    end
    configs = all_mappings.select { |school_profile_config_json| (school_profile_config_json.state == nil) }
    if !state.nil?
      configs += all_mappings.select { |school_profile_config_json| (school_profile_config_json.state && (school_profile_config_json.state.downcase == state.downcase)) }
    end
    configs
  end
end
