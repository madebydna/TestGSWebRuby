require_relative 'sharded_database_column_fetcher'

class GsIdsFetcher
  COLUMN = 'id,state_id'

  def initialize(host, state, table)
    @host = host
    @state = state.downcase
    @table = table
  end

  def values_array
    fetcher.values_array
  end

  def column
    fetcher.column
  end

  def hash
    fetcher.column.each_with_object({}) { |v, hash| hash[v.values.last] = v.values.first }
  end

  private
  def fetcher
    @_fetcher ||= (
      ShardedDatabaseColumnFetcher.new(@host, @state, @table, COLUMN, where)
    )
  end

  def where
    "where state_id != ''"
  end
end