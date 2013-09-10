class School < ActiveRecord::Base
  attr_accessible :name, :state, :school_collections

  has_many :school_collections
  has_many :collections, through: :school_collections
  has_many :esp_responses

=begin
  def label_value_map_per_category(page)
    categories_per_position = page.categories_per_position(collections)

    categories_per_position.values.each do |category|
      result = category.values_for_school(school)
    end
  end
=end

end
