require 'active_support/concern'

module StateSharding
  extend ActiveSupport::Concern

=begin
Example of sharding. This seems to work, but just using on_db to switch dbs seems to work for us right now

  SHARDING_MAP = {                        # This hash will map our keys to db connections
    'ca'      => :ca,
    'dc'      => :dc,
    'MI'      => :mi,
    :default  => :dc
  }

  DbCharmer::Sharding.register_connection(
    :name   => :ca,
    :method => :hash_map,
    :map    => SHARDING_MAP               # Pass our map to the sharding method
  )
=end

  included do
    db_magic :connection => :ca, slave: :ca
=begin
    db_magic :connection => :dc, :sharded => {
      :sharded_connection => :ca,
      :key => :state
    }
=end

    # Given a connection like gs_schooldb or ca, return the rw version
    def self.master_version_of_connection(connection_name)
      connection_name = connection_name.to_s
      if connection_name.index('_ro')
        connection_name.sub! '_ro', '_rw'
      else
        connection_name << '_rw'
      end

      # TODO: rename xx connections to xx_rw, and rename xx_ro connections to xx in database.yml, then remove this line of code
      connection_name.sub! '_rw', ''

      connection_name.to_sym
    end

    def self.prevent_chaining_without_on_db?
      true
    end
  end

  def shard
    state = self.state || 'ca'
    state.downcase.to_sym
  end

  def retrieved_from_shard
    @retrieved_from_shard
  end
  def set_retrieved_from_shard(shard)
    @retrieved_from_shard = shard
  end

end

