class SchoolProfileConfiguration < ActiveRecord::Base
  attr_accessible :configuration_key, :state, :value

  self.table_name = 'school_profile_configurations'
  db_magic :connection => :profile_config
  attr_accessible :state, :configuration_key, :value

  def self.for_state(state = nil)
    all_mappings = Rails.cache.fetch('school_profile_configurations/all', expires_in: 5.minutes) do
      self.all
    end
    configs = all_mappings.select { |school_profile_configuration| (school_profile_configuration.state.blank?) }
    if !state.nil?
      configs += all_mappings.select { |school_profile_configuration| (school_profile_configuration.state && (school_profile_configuration.state.downcase == state.downcase)) }
    end
    configs
  end
end
