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
    if (base.instance_variable_get :@group_comparison_data_reader).nil?
      base.instance_variable_set :@group_comparison_data_reader, GroupComparisonDataReader.new(base)
    end
    if (base.instance_variable_get :@community_spotlights_data_reader).nil?
      base.instance_variable_set :@community_spotlights_data_reader, CommunitySpotlightsDataReader.new(base)
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
    if (base.instance_variable_get :@performance_data_reader).nil?
      base.instance_variable_set :@performance_data_reader, PerformanceDataReader.new(base)
    end
    if (base.instance_variable_get :@details_overview_data_reader).nil?
      base.instance_variable_set :@details_overview_data_reader, DetailsOverviewDataReader.new(base)
    end
    if (base.instance_variable_get :@nearby_schools_data_reader).nil?
      base.instance_variable_set :@nearby_schools_data_reader, NearbySchoolsDataReader.new(base)
    end
  end

  def page=(page)
    @page = page
  end

  def page
    @page
  end

  def data_reader_config
    {
      census_data: @census_data_reader,
      census_data_points: @census_data_reader,
      cta_prek_only: @cta_prek_only_data_reader,
      details: @details_data_reader,
      esp_data_points: @esp_data_points_data_reader,
      esp_response: @esp_data_reader,
      group_comparison_data: @group_comparison_data_reader,
      community_spotlights: @community_spotlights_data_reader,
      rating_data: @rating_data,
      snapshot: @snapshot_data_reader,
      performance: @performance_data_reader,
      details_overview: @details_overview_data_reader,
      nearby_schools: @nearby_schools_data_reader,
      test_scores: @test_scores_data_reader
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
      group_comparison_data
      community_spotlights
      rating_data
      snapshot
      performance
      details_overview
      nearby_schools
      test_scores
      census_data_points
      footnotes
      enrollment
    ]
  end

  def category_source_key(category, source=category.source)
    "#{category.id}#{source}"
  end

  def category_key(category)
    category.present? ? "#{category.id}" : 'nil'
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
    data_key = category_source_key(category, source)
    @data[data_key] ||= (
      if source.present? && SchoolProfileDataDecorator.data_readers.include?(source)
        self.send source, options
      else
        nil
      end
    )
  end

  def footnotes_for_category(options)
    category = options[:category]
    raise(ArgumentError, ':category must be provided') if category.nil?

    source = category.source
    if source
      _memoize(:footnotes_for_category, category_source_key(category)) do
        data_reader_config[source.to_sym].try :footnotes_for_category, category
      end
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

  def pcsb_rating
    rating_data.fetch('pcsb_rating',{}).fetch('overall_rating',nil)
  end

  def preK_star_rating
    rating_data.fetch('preschool_rating',{}).fetch('overall_rating',nil)
  end

  def school_data(category = nil)
    hash = {}
    hash['district'] = district.name if district.present?
    hash['type'] = subtype
    hash
  end

  def _memoize(key, sub_key = 'nil')
    @__memoize ||= Hash.new({})
    @__memoize[key][sub_key] ||= yield
  end

  ##############################################################################
  # Methods exposed as "data readers" to rails admin UI start here

  def census_data(options = {})
    category = options[:category]
    _memoize(:census_data, category_key(category)) { @census_data_reader.labels_to_hashes_map category }
  end

  def census_data_points(_ = {})
    _memoize(:census_data_points) { @census_data_reader.data_type_descriptions_to_school_values_map }
  end

  def cta_prek_only(options = {})
    category = options[:category]
    _memoize(:cta_prek_only, category_key(category)) { @cta_prek_only_data_reader.data_for_category category }
  end

  def details(options = {})
    category = options[:category]
    _memoize(:details, category_key(category)) { @details_data_reader.data_for_category category }
  end

  def esp_data_points(options = {})
    category = options[:category]
    _memoize(:esp_data_points, category_key(category)) { @esp_data_points_data_reader.data_for_category category }
  end

  def esp_response(options = {})
    category = options[:category]
    _memoize(:esp_response, category_key(category)) { @esp_data_reader.data_for_category(category) }
  end

  def group_comparison_data(options = {})
    category = options[:category]
    _memoize(:group_comparison_data, category_key(category)) { @group_comparison_data_reader.data_for_category category }
  end

  def community_spotlights(options = {})
    category = options[:category]
    _memoize(:community_spotlights, category_key(category)) { @community_spotlights_data_reader.data_for_category category }
  end

  def rating_data(_ = {})
    @rating_data ||= @rating_data_reader.data
  end

  def snapshot(options = {})
    category = options[:category]
    _memoize(:snapshot, category_key(category)) { @snapshot_data_reader.data_for_category category }
  end

  def performance(options = {})
    category = options[:category]
    _memoize(:performance, category_key(category)) { @performance_data_reader.data_for_category category }
  end

  def details_overview(options = {})
    category = options[:category]
    _memoize(:details_overview, category_key(category)) { @details_overview_data_reader.data_for_category category }
  end

  def nearby_schools(options = {})
    category = options[:category]
    _memoize(:nearby_schools, category_key(category)) { @nearby_schools_data_reader.data_for_category category }
  end

  def test_scores(_ = {})
    _memoize(:test_scores) { @test_scores_data_reader.data }
  end

  def enrollment(options = {})
    category = options[:category]
    _memoize(:enrollment, category_key(category)) do
      hash = @esp_data_reader.responses_for_category category
      hash.gs_transform_values! { |array| array.first }
    end
  end

  def footnotes(options = {})
    category = options[:category]
    page_config = options[:page_config]
    raise(ArgumentError, ':page_config and :category must be provided') if page_config.nil? || category.nil?

    root_placements = page_config.root_placements

    root_placements.each_with_object([]) do |root, footnotes_array|
      leaves = root.has_children? ? root.leaves : [ root ]
      leaves.each do |leaf|
        # Skip if category is for footnotes, otherwise infinite recursion
        next if (leaf.category.nil? || leaf.category.id == category.id)
        footnotes = footnotes_for_category category: leaf.category
        parent = leaf.parent
        if footnotes.present?
          footnotes.each do |footnote|
            year = footnote[:year]
            label = (leaf.root? || parent.root?) ? leaf.title : parent.title
            footnote_year = year.to_s.to_i == 0 ? '' : ", #{year.to_i - 1}-#{year}"
            footnotes_array << {
              label: I18n.db_t(label),
              value: "#{footnote[:source]}#{footnote_year}"
            }
          end
        end
      end
    end.uniq
  end

end
