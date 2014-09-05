class SchoolCompareConfig
  attr_accessor :display_type, :children, :has_children, :opt

  def initialize(map)
    @display_type = map[:display_type]
    @opt = map[:opt]
    @children = map[:children].present? ? [*map[:children]].map { |child| SchoolCompareConfig.new(child)} : nil
    @has_children = @children.present?
  end
end