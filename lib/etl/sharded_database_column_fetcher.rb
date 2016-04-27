require 'mysql2'

class ShardedDatabaseColumnFetcher
  def initialize(host, state, table, column, where = '')
    @host = host
    @state = state.downcase
    @table = table
    @column = column
    @where = where
    @client = ::Mysql2::Client.new(:host => @host, :username=>'service', :password=>'service')
  end

  def column
    results
  end

  def values_array
    results.map { |v| v.values.first }
  end

  private
  def query
    "SELECT #{@column} from _#{@state}.#{@table} " + @where
  end

  def results
    @_results ||= (
      @client.query(query).to_a
    )
  end
end
