class School < ActiveRecord::Base
  self.table_name='school'

  attr_accessible :name, :state, :school_collections
  has_many :school_metadatas
  #has_many :school_collections
  #has_many :collections, through: :school_collections
  #has_many :census_data_school_values, :class_name => 'CensusDataSchoolValue'

  self.inheritance_column = nil

  def census_data_for_data_types(data_types = [])
    CensusDataSet.using(state.upcase.to_sym).by_data_types(state, data_types)
  end

  def census_data_school_values
    CensusDataSchoolValue.using(state.upcase.to_sym).where(school_id: id)
  end

  def self.all
    School.using(:CA).all
  end

  def school_collections
    SchoolCollection.using(:master).where(state: state, school_id: id)
  end

  def collections
    school_collections.map(&:collection)
  end

  # get the schools metadata
  def school_metadata
    schoolMetadata = Hashie::Mash.new()
    school_metadatas.each do |metadata|
      schoolMetadata[metadata.meta_key] = metadata.meta_value
    end
    return schoolMetadata
  end

  # returns all reviews for
  def reviews
    SchoolRating.fetch_reviews self, '', '', '', ''
  end
  def reviews_filter(group_type, order_results_by, offset_start, quantity_to_return)
    #second parameter is group to filter by leave it as empty string '' for all
    #third parameter is order by - options are
    #   '' empty string is most recent first
    #   'oldest' is oldest first
    #   'rating_top' is by highest rating
    #   'rating_bottom' is by lowest rating
    SchoolRating.fetch_reviews self, group_type, order_results_by, offset_start, quantity_to_return
  end

  def test_scores
    TestDataSet.fetch_test_scores self
  end

  def enrollment
    CensusData.data_for_school(self)['Enrollment'].first.school_value
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
