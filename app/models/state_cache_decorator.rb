# frozen_string_literal: true

class StateCacheDecorator
  attr_reader :state, :cache_data

  def initialize(state, cache_data = {})
    @state = state
    @cache_data = cache_data
  end

  def self.for_state(state, *keys)
    query_results = StateCacheQuery.for_state(state).include_cache_keys(keys).query
    require 'pry'; binding.pry
    StateCacheResults.new(keys, query_results).decorate_city(city)
  end

  def method_missing(meth, *args)
    if @state.respond_to?(meth)
      @state.send(meth, *args)
    else
      super
    end
  end

  def respond_to?(meth)
    @state.respond_to?(meth)
  end

  def respond_to_missing?(meth, include_private=false)
    @state.respond_to_missing?(meth, include_private)
  end
end
