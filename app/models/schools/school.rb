class School < ActiveRecord::Base
  include ActionView::Helpers
  self.table_name='school'
  include StateSharding

  attr_accessible :name, :state, :school_collections, :district_id
  has_many :school_metadatas
  belongs_to :district

  self.inheritance_column = nil

  def census_data_for_data_types(data_types = [])
    CensusDataSet.on_db(state.downcase.to_sym).by_data_types(state, data_types)
  end

  def census_data_school_values
    CensusDataSchoolValue.on_db(state.downcase.to_sym).where(school_id: id)
  end

  def school_collections
    SchoolCollection.for_school(self)
  end

  def collections
    school_collections.map(&:collection).uniq
  end

  # get the schools metadata
  def school_metadata
    schoolMetadata = Hashie::Mash.new()
    on_db(shard).school_metadatas.each do |metadata|
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

# returns true or false - takes p,e,m,h as an array
  def includes_level_code? (arr_levels)
    (level_code_array & (Array(arr_levels))).any?
  end

  def private_school?
    type == 'private'
  end

  def includes_preschool?
    includes_level_code? 'p'
  end

  def level_code_array
    level_code.split ','
  end

  def process_level

    level_array = level.split ','

    # need to find contiguous grade levels and insert a dash "-" between first and last
    # pre K or PK is smallest
    # KG or K is second smallest - convert KG to K
    # Breaks in grade sequence is separated by a comma
    # UG if alone will be written as Ungraded if at the end of a series append as "& Ungraded"

    if level_array.length == 1
      if level_array[0] == 'KG'
        return 'K'
      elsif level_array[0] == 'UG'
        return "Ungraded"
      end
      return level_array[0]
    end

    ungraded = false
    result = []
    level_array.each_with_index do | value, index |
      if value == 'PK'
        result[index] = -1
      elsif (value == 'KG' || value == 'K' )
        result[index] = 0
      elsif (value == 'UG' )
        ungraded = true
      else
        result[index] = value.to_i
      end
    end



    # set first value
    if result.empty?
      if ungraded == true
         return "Ungraded"
      end
      return nil
    end

    array_count = result.length - 1
    first_value = result[0]

    return_str = ''
    # just so it is not one less then the first value.
    series_started = false
    previous_value = first_value

    for i in 1..array_count
      value = result[i]
      if value == previous_value + 1
        if series_started == false
          if return_str != ''
            return_str += ', '
          end
          if previous_value == -1
            return_str += 'PK'
          elsif previous_value == 0
              return_str += '-K'
          else
            if value == 5
              raise('')
            end
            return_str += previous_value.to_s
          end
        end
        if i == array_count
          if value == 0
            return_str += '-K'
          else
            return_str += '-' + value.to_s
          end
          next
        end

        previous_value = value
        series_started = true
        next
      end

      if previous_value == -1
        return_str += 'PK'
      elsif previous_value == 0
        if series_started
          return_str += '-K'
        else
          return_str += 'K'
        end
      elsif i == array_count
        if series_started
          return_str += '-'
        end
        return_str += previous_value.to_s + ', ' + value.to_s
      elsif series_started
        return_str += '-' + value.to_s
      end

      series_started = false
      previous_value = value
    end
    if ungraded == true
      return_str += " & Ungraded"
    end
    return_str
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
    TestScoreResults.new.fetch_test_scores self
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

  #Temporary work around, since with db charmer we cannot directly say school.district.name.
  #It looks at the wrong database in that case.
  def district
    @district ||= District.on_db(self.shard).where(id: self.district_id).first
  end

  # returns true if school is on held school list (associated with school reviews)
  def held?
    # TODO: implementation
    return false
  end

  def gs_rating
    rating_data = CategoryDataReader.rating_data self, nil
    rating_data.fetch('gs_rating',{}).fetch('overall_rating',nil)
  end

  def local_rating
    rating_data = CategoryDataReader.rating_data self, nil
    rating_data.fetch('city_rating',{}).fetch('overall_rating',nil)
  end

  def state_rating
    rating_data = CategoryDataReader.rating_data self, nil
    rating_data.fetch('state_rating',{}).fetch('overall_rating',nil)
  end

end
