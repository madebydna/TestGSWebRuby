require 'states'
class SchoolCollection < ActiveRecord::Base
  attr_accessible :collection, :schools, :collection_id, :school_id, :state
  has_paper_trail
  db_magic :connection => :profile_config

  belongs_to :school
  belongs_to :collection

  def state_hash
    States::state_hash.values
  end

  def school
    return nil if school_id.nil? || state.nil?

    shard = state
    shard = 'ca' if shard.nil? || shard == ''
    shard = shard.downcase.to_sym
    School.on_db(shard).find school_id
  end

  def school=(school)
    @state = school.state
    @school_id = school.id
  end
end
