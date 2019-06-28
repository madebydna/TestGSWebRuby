class StateCacheDecorator

  attr_reader :state, :cache_data

  def initialize(state, cache_data = {})
    @state = state
    @cache_data = cache_data
  end
end
