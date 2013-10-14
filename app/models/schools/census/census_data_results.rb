require 'forwardable'

class CensusDataResults
  include Enumerable
  extend Forwardable
  def_delegators :@results, :each, :<<, :select!, :empty?, :[]

  def initialize(results)
    @results = results
  end

  # won't filter out year zero
  # "latest" = most recent year for the state
  def filter_to_max_year_per_data_type!(state)
    max_years = CensusDataSet.max_year_per_data_type(state)
    select! { |result| result.year == 0 || max_years[result.data_type_id] == result.year }
    self
  end

  def for_data_type!(data_type)
    if data_type.is_a? Fixnum
      select! { |census_data_set| census_data_set.census_data_type.id == data_type }
    else
      select! { |census_data_set| census_data_set.data_type.downcase == data_type.to_s.downcase }
    end
  end



end