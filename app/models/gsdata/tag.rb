class Tag < ActiveRecord::Base
  self.table_name = 'breakdown_tags'
  database_config = Rails.configuration.database_configuration[Rails.env]["gsdata"]
  self.establish_connection(database_config)

  attr_accessible :tag, :active, :breakdown
  alias_attribute :name, :tag

  belongs_to :breakdown, inverse_of: :tags

  def self.from_hash(hash)
    self.name = hash['tag']
    self.active = hash['active']
  end
end
