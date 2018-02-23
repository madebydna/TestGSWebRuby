# frozen_string_literal: true

class Tag < ActiveRecord::Base
  self.table_name = 'breakdown_tags'
  db_magic connection: :gsdata

  attr_accessible :tag, :active, :breakdown
  alias_attribute :name, :tag

  belongs_to :breakdown, inverse_of: :tags

  def self.from_hash(hash)
    self.name = hash['tag']
    self.active = hash['active']
  end
end
