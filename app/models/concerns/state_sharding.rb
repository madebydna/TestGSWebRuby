require 'active_support/concern'

module StateSharding
  extend ActiveSupport::Concern

  included do
    db_magic :connection => :ca
  end

  def shard
    state = self.state || 'ca'
    state.downcase.to_sym
  end

end