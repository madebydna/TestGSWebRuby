require 'mysql2'
require_relative '../source'

class GsShardedDatabaseSource < GS::ETL::Source
  def initialize(args)
    args.fetch(:host, 'datadev.greatschools.org')
    args.fetch(:state, 'ca')
    args.fetch(:table, 'school')
    args.fetch(:where, '')
    @host = host
    @state = state.downcase
    @table = table
    @where = where
    @client = ::Mysql2::Client.new(:host => @host, :username=>'service', :password=>'service')
  end

  def each
    @csv.each do |row|
      yield(row.to_hash)
    end
    @csv.close
  end

  def event_key
    @input_file
  end
end
