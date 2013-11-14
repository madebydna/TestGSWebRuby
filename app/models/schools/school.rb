class School < ActiveRecord::Base
  include ActionView::Helpers
  self.table_name='school'
  include StateSharding

  attr_accessible :name, :state, :school_collections, :district_id
  has_many :school_metadatas
  #has_many :school_collections
  #has_many :collections, through: :school_collections
  #has_many :census_data_school_values, :class_name => 'CensusDataSchoolValue'

  self.inheritance_column = nil

  def census_data_for_data_types(data_types = [])
    CensusDataSet.on_db(state.downcase.to_sym).by_data_types(state, data_types)
  end

  def census_data_school_values
    CensusDataSchoolValue.on_db(state.downcase.to_sym).where(school_id: id)
  end

  def self.all
    School.on_db(:CA).all
  end

  def school_collections
    SchoolCollection.where(state: state, school_id: id)
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

  def school_media_first_hash
    result = SchoolMedia.fetch_school_media self, 1
    result.first['hash']  unless result.nil? || result.empty?
  end

  def school_media
    SchoolMedia.fetch_school_media self, ''
  end

  def process_level
    l = level.split ','
    case l.size
      when 1
        l.first
      when 0
        nil
      else
        l.first + "-" + l.last
    end
  end

  # returns all reviews for
  def reviews
    SchoolRating.fetch_reviews self
  end

  # group_to_fetch, order_results_by, offset_start, quantity_to_return
  def reviews_filter( options ={} )
    #second parameter is group to filter by leave it as empty string '' for all
    #third parameter is order by - options are
    #   '' empty string is most recent first
    #   'oldest' is oldest first
    #   'rating_top' is by highest rating
    #   'rating_bottom' is by lowest rating
    SchoolRating.fetch_reviews self, group_to_fetch: options[:group_type], order_results_by: options[:order_results_by], offset_start: options[:offset_start], quantity_to_return: options[:quantity_to_return]
  end

  def test_scores
    TestDataResults.new.fetch_results self
  end

  def enrollment
    enrollment = CategoryDataReader.enrollment(self, nil)
    if enrollment
      number_with_delimiter(enrollment.to_i, :delimiter => ',')
    end
  end

  def state_name
    States.state_name(state)
  end

  def level_codes
    level_code.split(',') if level_code.present?
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
