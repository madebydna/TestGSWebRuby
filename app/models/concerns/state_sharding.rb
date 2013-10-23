require 'active_support/concern'

module StateSharding
  extend ActiveSupport::Concern

  included do
    db_magic :connection => :ca, slave: :ca

    def self.first_level_on_slave
      first_level = db_charmer_top_level_connection? && on_master.connection.open_transactions.zero?
      if db_charmer_force_slave_reads? && db_charmer_slaves.any?
        if first_level
          current_db = db_charmer_connection_proxy.connection_name
          # puts "current db: #{current_db}"
          on_slave { yield }
        else
          current_db = db_charmer_connection_proxy.connection_name
          # puts "current db: #{current_db}"
          slave_name = "#{current_db}_ro"
          # puts "slave:  #{slave_name}"
          if ActiveRecord::Base.configurations[DbCharmer.env][slave_name]
            on_slave(slave_name) { yield }
          else
            yield
          end
        end
      end
    end

  end

  def shard
    state = self.state || 'ca'
    state.downcase.to_sym
  end

end