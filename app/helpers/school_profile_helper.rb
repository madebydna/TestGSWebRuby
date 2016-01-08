module SchoolProfileHelper
  include ConfiguredTableHelper
  include DataDisplayHelper

  def category_placement_anchor(category_placement)
    "#{category_placement_title category_placement}".gsub(/\W+/, '_')
  end

  def category_placement_title(category_placement)
    category_placement.title || category_placement.category.name
  end

  def category_placement_data(page_config, category_placement)
    @data_cache ||= {}
    if category_placement.category
      @data_cache[category_placement] ||= @school.data_for_category category: category_placement.category
    end
  end

end
