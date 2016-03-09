require 'sharded_database_column_fetcher'

class GsSchoolIdsFetcher
  STATE_ID_FIELD = 'state_id'
  TABLE = 'school'

  def initialize(host, state)
    @host = host
    @state = state.downcase
  end

  def values_array
    fetcher.values_array
  end

  def column
    fetcher.column
  end

  private
  def fetcher
    @_fetcher ||= (
      ShardedDatabaseColumnFetcher.new(@host, @state, TABLE, STATE_ID_FIELD, where)
    )
  end

  def where
    "where state_id != ''"
  end
end
