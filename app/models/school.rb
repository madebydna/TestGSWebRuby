class School < ActiveRecord::Base
  self.table_name='school'

  attr_accessible :name, :state, :school_collections

  #has_many :school_collections
  #has_many :collections, through: :school_collections
  #has_many :census_data_school_values, :class_name => 'CensusDataSchoolValue'

  self.inheritance_column = nil

  def census_data_for_data_types(data_types = [])
    CensusDataSet.using(state.upcase.to_sym).by_data_types(state, data_types)
  end

  def self.all
    School.using(:CA).all
  end

  def school_collections
    SchoolCollection.where(state: state, school_id: id)
  end

  def collections
    school_collections.map(&:collection)
  end


=begin
  def label_value_map_per_category(page)
    categories_per_position = page.categories_per_position(collections)

    categories_per_position.values.each do |category|
      result = category.values_for_school(school)
    end
  end
=end

end
