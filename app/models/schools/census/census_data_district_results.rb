require 'forwardable'

class CensusDataDistrictResults < CensusDataResults
  include Enumerable
  extend Forwardable
  def_delegators :@results,
                 :each,
                 :<<,
                 :select!,
                 :reject!,
                 :empty?,
                 :[],
                 :-,
                 :replace,
                 :delete,
                 :size

  def initialize(results)
    super
  end

  def max_year_per_data_type
    data_types = group_by(&:data_type_id)

    max_years = {}
    data_types.each do |k,v|
      # Save all data
      @all_results.push(*v)

      # Throw out years where associated values are nil
      data_with_district_values = v.reject { |data_set| data_set.census_data_district_value.nil? }

      # Find max of remaining years
      max_year = data_with_district_values.map(&:year).max

      # If there's any valid year zero overrides, use those
      max_year = 0 if v.select do |data_set|
        data_set.year == 0 &&
            data_set.census_data_district_value &&
            # Is the year zero override recent enough?
            data_set.census_data_district_value.modified > Time.new(max_year - 1, 10, 1)
      end.any?
      max_years[k] = max_year
    end

    max_years
  end


end