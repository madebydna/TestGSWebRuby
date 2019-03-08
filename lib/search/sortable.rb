# frozen_string_literal: true

module Search
  # You probably want to implement these methods:
  #
  # - valid_sort_names
  # - default_sort_name
  # - default_sort_direction
  # - map_sort_name_and_direction
  module Sortable

    def sort_name=(name)
      return unless name
      @sort_name = name
    end

    def sort_direction=(direction)
      return unless direction
      options = valid_sort_directions.join(', ')
      unless sort_direction_valid?(direction)
        raise ArgumentError.new("Sort direction '#{direction}' not present in (#{options}) in #{self.class.name}")
      end
      @sort_direction = direction
    end

    def sort_field
      map_sort_name_to_field(sort_name, sort_direction) || default_sort_field
    end

    def sort_direction
      map_sort_direction(sort_name, @sort_direction) || default_sort_direction
    end

    # def sort_name_valid?(name)
    #   valid_sort_names.include?(name)
    # end

    def sort_direction_valid?(direction)
      valid_sort_directions.include?(direction)
    end

    private

    def valid_sort_directions
      ["asc", "desc"]
    end

    def sort_name
      @sort_name || default_sort_name
    end

    # def valid_sort_names
    #   raise NotImplementedError.new("#valid_sort_names not implemented in #{self.class.name}")
    #   # e.g. ['rating', 'school_name']
    # end

    def default_sort_name
      nil
    end

    def default_sort_field
      nil
    end

    def default_sort_direction
      nil
    end

    def map_sort_name_to_field(name, direction)
      raise NotImplementedError.new("#map_sort_name_to_field not implemented in #{self.class.name}")
    end

    def map_sort_direction(name, direction)
      return direction
    end
  end
end
