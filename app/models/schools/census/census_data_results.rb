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
  def filter_to_max_year_per_data_type!
    max_years = max_year_per_data_type
    select! { |result| max_years[result.data_type_id] == result.year }
    self
  end

  # For each data type in results, determine the maximum valid year for that data type
  # Valid years are years that have at least one school value for this school, or
  # year zeros where the school's modified date is later than october prior to (max data set year)
  def max_year_per_data_type
    data_types = group_by(&:data_type_id)

    max_years = {}
    data_types.each do |k,v|
      # Throw out years where associated values are nil. Find max of remaining years
      max_year = v.reject { |data_set| data_set.census_data_school_value.nil? }.map(&:year).max

      # If there's any valid year zero overrides, use those
      max_year = 0 if v.select do |data_set|
        data_set.year == 0 &&
        data_set.census_data_school_value &&
        # Is the year zero override recent enough?
        data_set.census_data_school_value.modified > Time.new(max_year - 1, 10, 1)
      end.any?
      max_years[k] = max_year
    end

    max_years
  end

  def for_data_type!(data_type)
    if data_type.is_a? Fixnum
      select! { |census_data_set| census_data_set.census_data_type.id == data_type }
    else
      select! { |census_data_set| census_data_set.data_type.downcase == data_type.to_s.downcase }
    end
  end

  def for_data_types(data_types)
    data_types = Array(data_types).clone

    data_types.each do |data_type|
      data_type.downcase! if data_type.is_a? String
    end

    select do |census_data_set|
      data_types.include?(census_data_set.data_type.downcase) || data_types.include?(census_data_set.census_data_type.id)
    end
  end



end