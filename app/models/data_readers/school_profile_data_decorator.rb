module SchoolProfileDataDecorator

  def self.extended(base)
    if (base.instance_variable_get :@census_data_reader).nil?
      base.instance_variable_set :@census_data_reader, CensusDataReader.new(base)
    end
    if (base.instance_variable_get :@cta_prek_only_data_reader).nil?
      base.instance_variable_set :@cta_prek_only_data_reader, CtaPrekOnlyDataReader.new(base)
    end
    if (base.instance_variable_get :@details_data_reader).nil?
      base.instance_variable_set :@details_data_reader, DetailsDataReader.new(base)
    end
    if (base.instance_variable_get :@esp_data_points_data_reader).nil?
      base.instance_variable_set :@esp_data_points_data_reader, EspDataPointsDataReader.new(base)
    end
    if (base.instance_variable_get :@esp_data_reader).nil?
      base.instance_variable_set :@esp_data_reader, EspDataReader.new(base)
    end
    if (base.instance_variable_get :@rating_data_reader).nil?
      base.instance_variable_set :@rating_data_reader, RatingDataReader.new(base)
    end
    if (base.instance_variable_get :@snapshot_data_reader).nil?
      base.instance_variable_set :@snapshot_data_reader, SnapshotDataReader.new(base)
    end
    if (base.instance_variable_get :@test_scores_data_reader).nil?
      base.instance_variable_set :@test_scores_data_reader, TestScoresDataReader.new(base)
    end
    if (base.instance_variable_get :@zillow_data_reader).nil?
      base.instance_variable_set :@zillow_data_reader, ZillowDataReader.new(base)
    end
  end

  # Methods exposed as "data readers" to rails admin UI
  def data_readers
    %w[
      census_data
      cta_prek_only
      details
      esp_data_points
      esp_response
      rating_data
      snapshot
      test_scores
      zillow
      census_data_points
    ]
  end

  def data_for_category(category)
    data_for_category_and_source category, category.source
  end

  def data_for_category_and_source(category, source)
    @data ||= {}
    data_key = category.nil? ? source : "#{category.id}#{source}"
    return @data[data_key] if @data.has_key? data_key

    if source.present? && data_readers.include?(source)
      result = self.send source, category
      @data[data_key] = result
    end
  end

  def gs_rating
    rating_data.fetch('gs_rating',{}).fetch('overall_rating',nil)
  end

  def local_rating
    rating_data.fetch('city_rating',{}).fetch('overall_rating',nil)
  end

  def state_rating
    rating_data.fetch('state_rating',{}).fetch('overall_rating',nil)
  end

  def preK_star_rating
    rating_data.fetch('preK_ratings',{}).fetch('star_rating',nil)
  end

  def school_data(category = nil)
    hash = {}
    hash['district'] = district.name if district.present?
    hash['type'] = subtype
    hash
  end

  ##############################################################################
  # Methods exposed as "data readers" to rails admin UI start here

  def census_data(category)
    @census_data_reader.labels_to_hashes_map category
  end

  def census_data_points(category = nil)
    @census_data_reader.data_type_descriptions_to_school_values_map
  end

  def cta_prek_only(category)
    @cta_prek_only_data_reader.data_for_category category
  end

  def details(category)
    @details_data_reader.data_for_category category
  end

  def esp_data_points(category)
    @esp_data_points_data_reader.data_for_category category
  end

  def esp_response(category)
    @esp_data_reader.data_for_category category
  end

  def rating_data(category = nil)
    @rating_data_reader.data
  end

  def snapshot(category)
    @snapshot_data_reader.data_for_category category
  end

  def test_scores(category)
    @test_scores_data_reader.data_for_category category
  end

  def zillow(category)
    @zillow_data_reader.data_for_category category
  end



end