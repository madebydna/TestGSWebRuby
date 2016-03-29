require 'mysql2'
require_relative '../etl'
require 'source'

class GsShardedDatabaseSource < GS::ETL::Step
  include GS::ETL::Source

  def initialize(args)
    @host = args.fetch(:host, 'datadev.greatschools.org')
    @state = args.fetch(:state, 'ca').downcase
    @table = args.fetch(:table, 'school')
    @where = args.fetch(:where, '')
    @client = Mysql2::Client.new(:host => @host, :username=>'service', :password=>'service')
  end

  def each(*args, &block)
    results.each(*args, &block)
  end

  def event_key
    query
  end

  private

  def query
    "SELECT * from _#{@state}.#{@table} " + @where
  end

  def results
    @_results ||= (
      @client.query(query)
    )
  end

end

