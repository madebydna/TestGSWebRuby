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

  def data_reader_config
    {
      census_data: @census_data_reader,
      census_data_points: @census_data_reader,
      cta_prek_only: @cta_prek_only_data_reader,
      details: @details_data_reader,
      esp_data_points: @esp_data_points_data_reader,
      esp_response: @esp_data_reader,
      rating_data: @rating_data,
      snapshot: @snapshot_data_reader,
      test_scores: @test_scores_data_reader,
      zillow: @zillow_data_reader
    }
  end

  # Methods exposed as "data readers" to rails admin UI
  def self.data_readers
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
      footnotes
    ]
  end

  def data_for_category(options = {})
    category = options[:category]
    raise(ArgumentError, ':category must be provided') if category.nil?

    options[:source] = category.source
    data_for_category_and_source options
  end

  def data_for_category_and_source(options)
    category = options[:category]
    source = options[:source]
    raise(ArgumentError, ':category and :source must both be provided') if category.nil? || source.nil?


    @data ||= {}
    data_key = category.nil? ? source : "#{category.id}#{source}"
    return @data[data_key] if @data.has_key? data_key

    if source.present? && SchoolProfileDataDecorator.data_readers.include?(source)
      result = self.send source, options
      @data[data_key] = result
    end
  end

  def footnotes_for_category(options)
    category = options[:category]
    raise(ArgumentError, ':category must be provided') if category.nil?

    source = category.source
    if source
      reader = data_reader_config[source.to_sym]
      return reader.send :footnotes_for_category, category if reader.respond_to? :footnotes_for_category
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

  def census_data(options = {})
    category = options[:category]
    @census_data_reader.labels_to_hashes_map category
  end

  def census_data_points(options = {})
    @census_data_reader.data_type_descriptions_to_school_values_map
  end

  def cta_prek_only(options = {})
    category = options[:category]
    @cta_prek_only_data_reader.data_for_category category
  end

  def details(options = {})
    category = options[:category]
    @details_data_reader.data_for_category category
  end

  def esp_data_points(options = {})
    category = options[:category]
    @esp_data_points_data_reader.data_for_category category
  end

  def esp_response(options = {})
    category = options[:category]
    @esp_data_reader.data_for_category category
  end

  def rating_data(options = {})
    @rating_data_reader.data
  end

  def snapshot(options = {})
    category = options[:category]
    @snapshot_data_reader.data_for_category category
  end

  def test_scores(options = {})
    category = options[:category]
    @test_scores_data_reader.data_for_category category
  end

  def zillow(options = {})
    category = options[:category]
    @zillow_data_reader.data_for_category category
  end

  def footnotes(options = {})
    category = options[:category]
    page_config = options[:page_config]
    raise(ArgumentError, ':page_config and :category must be provided') if page_config.nil? || category.nil?

    root_placements = page_config.root_placements

    root_placements.each_with_object([]) do |root, footnotes_array|
      leaves = page_config.category_placement_has_children?(root) ? page_config.category_placement_leaves(root) : [ root ]
      leaves.each do |leaf|
        # Skip if category is for footnotes, otherwise infinite recursion
        next if leaf.category.id == category.id
        footnotes = footnotes_for_category category: leaf.category
        parent = page_config.category_placement_parent leaf

        if footnotes.present?
          footnotes.each do |footnote|
            year = footnote[:year]
            label = (leaf.root? || parent.root?) ? leaf.title : parent.title
            footnotes_array << {
              label: label,
              value: "#{footnote[:source]}, #{year.to_i - 1}-#{year}"
            }
          end
        end
      end
    end.uniq
  end

end