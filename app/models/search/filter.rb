#ToDo Tests Needed
class Filter

  attr_accessor :name, :key, :display_type, :filters, :sort_order, :category

  def initialize(attributes)
    @name = attributes[:name]
    @key = attributes[:key] #only required for actual filters
    @display_type = attributes[:display_type] #required
    @filters = attributes[:filters]
    @category = attributes[:category] #only required for actual filters
    @sort_order = attributes[:sort_order] #for sorting the tree to have filters displayed in order
  end

  def filters_display_map #returns map for search result fit score map
    ###EXAMPLE map to return
    {
      girls_sports: {
        name: 'Girls Sports',
        soccer: 'Soccer',
        basketball: 'Basketball',
        football: 'Football'
      }
    }
    build_map(filters).each {|k, v| v.merge!(name: name)} unless filters.nil?
  end

  def build_map(filter)
    if (filter = [*filter][0]).filters.nil?
      { filter.category => { filter.key => filter.name } }
    else
      filter.filters.inject({}) do |hash, f|
        build_map(f).inject({}) do |h, (k, v)|
          hash.has_key?(k) ? hash[k].merge!(v) : hash.merge!({k => v}); hash
        end
      end
    end
  end

end

class SliderFilter < Filter
  def get_values_of_children #gets names and query_param_keys of children. For filters that need all values at once.
  end
end


