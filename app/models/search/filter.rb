#ToDo Tests Needed
class Filter

  attr_accessor :label, :name, :value, :display_type, :filters, :sort_order, :has_children

  def initialize(attributes)
    @label = attributes[:label]
    @value = attributes[:value] #only required for actual filters
    @display_type = attributes[:display_type] #required
    @filters = attributes[:filters]
    @name = attributes[:name] #only required for actual filters
    @sort_order = attributes[:sort_order] #for sorting the tree to have filters displayed in order
    @has_children = attributes[:filters].present?
  end

  def build_map #returns map for search result fit score map
    if self.has_children
      self.filters.inject({}) do |hash, f|
        map = f.build_map.inject({}) do |h, (k, v)|
          hash.has_key?(k) ? hash[k].merge!(v) : hash.merge!({k => v}) ; hash
        end
        [*f.name].each { |name| map[name].merge!({label: f.label}) } if f.display_type == :title ; map
      end
    else
      { self.name => { self.value => self.label } }
    end
  end

end

