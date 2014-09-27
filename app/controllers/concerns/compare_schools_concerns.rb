module CompareSchoolsConcerns
  extend ActiveSupport::Concern

  protected

  SCHOOL_CACHE_KEYS = %w(characteristics ratings esp_responses reviews_snapshot)
  OVERALL_RATING_NAME = 'GreatSchools rating'

  def prep_school_ethnicity_data!
    all_breakdowns = []
    @ethnicity_datapoints = []
    @schools.each do |school|
      school.school_cache.ethnicity_data.each do |ethnicity|
        if ethnicity.key? 'school_value'
          unless all_breakdowns.any? { |eth| eth == ethnicity['breakdown'] }
            all_breakdowns << ethnicity['breakdown']
          end
        end
      end
    end
    @schools.each do |school|
      school.prepped_ethnicities = []
      all_breakdowns.each do |breakdown|
        school_ethnicity = school.school_cache.ethnicity_data.find { |ethnicity| ethnicity['breakdown'] == breakdown }
        school_value = if school_ethnicity
                         school_ethnicity['school_value']
                       else
                         nil
                       end
        school.prepped_ethnicities << { 'breakdown' => breakdown, 'school_value' => school_value }
        unless @ethnicity_datapoints.any? { |datapoint| datapoint[:label] == breakdown }
          @ethnicity_datapoints << {
              method: :school_ethnicity, argument: breakdown,
              label: breakdown, icon: school.ethnicity_label_icon
          }
        end
      end
    end
    @ethnicity_datapoints.sort_by! { |datapoint| datapoint[:label] }
  end

  def prep_school_ratings!
    all_ratings = []
    @ratings_datapoints = []
    @schools.each do |school|
      school.school_cache.ratings.each do |rating|
        unless all_ratings.any? { |r| r == rating['name'] }
          all_ratings << rating['name']
        end
      end
    end
    ratings_labels = ratings_labels_from_config
    @schools.each do |school|
      all_ratings.each do |rating_name|
        school_rating = school.school_cache.ratings.find{ |r| r['name'] == rating_name }
        rating_id = school_rating.nil? ? nil : school_rating['data_type_id']
        label = ratings_labels[rating_id] ? ratings_labels[rating_id] : rating_name

        unless @ratings_datapoints.any? { |datapoint| datapoint[:label] == label }
          if rating_name == OVERALL_RATING_NAME
            @ratings_datapoints << { method: :great_schools_rating_icon, label: label, sort: rating_id}
          elsif ratings_labels.keys.include? rating_id
            @ratings_datapoints << { method: :school_rating_by_name, argument: rating_name, label: label, sort: rating_id}
          end
        end
      end
    end
    prep_ratings_display!
  end

  def ratings_labels_from_config
    ratings_labels = {}
    ratings_config = RatingsConfiguration.configuration_for_school(@state)
    ratings_config.each do |rating_type, rating_type_hash|
      if rating_type_hash.is_a?(Hash)
        # Only show sub-ratings for GS ratings
        rating_level = rating_type == 'gs_rating' ? 'rating_breakdowns' : 'overall'
        rating_description = rating_type_hash[rating_level]
        if rating_description.values.first.is_a?(Hash)
          rating_description.values.each do |description|
            if description['data_type_id']
              ratings_labels[description['data_type_id']] = description['label']
            end
          end
        elsif rating_description['data_type_id']
          ratings_labels[rating_description['data_type_id']] = rating_description['label']
        end
      end
    end
    ratings_labels
  end

  def decorated_schools
    schools_with_data = schools_with_caches
    prep_schools_for_compare!(schools_with_data)
  end

  def schools_with_caches
    db_schools = School.on_db(@state).where(id: @params_schools, active: true)
    db_schools = db_schools[0..3]

    query = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS)
    db_schools.each do |db_school|
      query = query.include_schools(db_school.state, db_school.id)
    end
    query_results = query.query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)
    school_cache_results.decorate_schools(db_schools)
  end

  def prep_schools_for_compare!(decorated_schools)
    filter_display_map = FilterBuilder.new.filter_display_map # for labeling fit score breakdowns
    decorated_schools.map do |school|
      decorated_school = SchoolCompareDecorator.decorate(school)
      decorated_school.calculate_fit_score!(session[:soft_filter_params] || {})
      unless decorated_school.fit_score_breakdown.nil?
        decorated_school.update_breakdown_labels! filter_display_map
        decorated_school.sort_breakdown_by_match_status!
      end
      decorated_school
    end
  end

  def compare_schools_list_mapping
    #ToDo If any module needs to be more data-base driven, you can add further levels into the hash
    #ToDo ex. currently display_type rating and college_readiness are just individually hard-coded partials. If needed, you can add more nesting/partials for more customizability
    {
        display_type: 'school',
        children: [
            { display_type: 'header' },
            {
                display_type: 'buttons',
                opt: {
                    datapoints:[
                        {method: :follow_this_school, label: 'Follow this school', icon:'iconx16 i-16-envelop', class:'btn btn-default tal clearfix js-save-this-school-button', form: true},
                    ]
                }
            },
            {
                display_type: 'category',
                opt: {
                    subtitle: 'Quality',
                    key: :quality
                },
                children: [
                    { display_type: 'label', opt: { label: 'Rating'} },
                    { display_type: 'quality/ratings' }
                ]
            },
            {
                display_type: 'fit',
                opt: {
                  subtitle: 'Fit criteria',
                  key: :fit
                }
            },
            {
                display_type: 'category',
                opt: {
                    subtitle: 'Reviews',
                    key: :reviews
                },
                children: [
                    {display_type: 'reviews_snapshot'}
                ]
            },
            {
                display_type: 'category',
                opt: {
                    subtitle: 'Details',
                    key: :details
                },
                children: [
                    { display_type: 'label', opt: { label: 'At a glance'} },
                    {
                        display_type: 'line_data',
                        opt: {
                            datapoints: [
                                {method: :students_enrolled, label: 'Students enrolled', icon: 'iconx16 i-16-blue-students-enrolled'},
                                {method: :transportation, label: 'Transportation', icon: 'iconx16 i-16-blue-transportation'},
                                {method: :before_care, label: 'Before care', icon: 'iconx16 i-16-blue-before-care'},
                                {method: :after_school, label: 'After school', icon: 'iconx16 i-16-blue-after-school'}
                            ]
                        }
                    },
                    { display_type: 'section_dividing_bar' },
                    { display_type: 'label', opt: { label: 'Programs'} },
                    {
                        display_type: 'line_data',
                        opt: {
                            datapoints: [
                                {method: :world_languages, label: 'World language', icon: 'iconx16 i-16-blue-world-languages'},
                                {method: :clubs, label: 'Clubs', icon: 'iconx16 i-16-blue-clubs'},
                                {method: :sports, label: 'Sports', icon: 'iconx16 i-16-blue-sports-trophy'},
                                {method: :arts_and_music, label: 'Arts & Music', icon: 'iconx16 i-16-blue-arts-and-music'}
                            ]
                        }
                    },
                    { display_type: 'section_dividing_bar' },
                    { display_type: 'label', opt: { label: 'Student Diversity'} },
                    { display_type: 'details/compare_pie_chart' },
                    {
                        display_type: 'details/ethnicities',
                        opt: {
                            table_name: 'js-comparePieChartTable'
                        }
                    }
                ]
            },
            {
                display_type: 'buttons',
                opt: {
                    datapoints:[
                      {method: :school_page_url, label: 'View full profile', class: 'btn btn-primary tac clearfix'},
                      {method: :follow_this_school, label: 'Follow this school', icon:'iconx16 i-16-envelop', class:'btn btn-default tal clearfix js-save-this-school-button', form: true},
                      {method: :zillow_formatted_url, label: 'Homes for sale', icon: 'iconx16 i-16-home ', class: 'btn btn-default tal clearfix' ,target: '_blank'},
                    ]
                }
            },
        ]
    }

  end

  def prep_ratings_display!
    overall_rating = @ratings_datapoints.find { |datapoint| datapoint[:label] == OVERALL_RATING_NAME }
    if overall_rating
      @ratings_datapoints -= [overall_rating]
      @ratings_datapoints.sort_by! { |datapoint| datapoint[:sort] }
      @ratings_datapoints = [overall_rating] + @ratings_datapoints
    elsif @ratings_datapoints.empty?
      @ratings_datapoints = [{ method: :great_schools_rating_icon, label: OVERALL_RATING_NAME}]
    else
      @ratings_datapoints.sort_by! { |datapoint| datapoint[:sort] }
      @ratings_datapoints = [{ method: :great_schools_rating_icon, label: OVERALL_RATING_NAME}] + @ratings_datapoints
    end
  end

  def set_back_to_search_results_instance_variable
    #search_url parameter is encoded in compare_schools_popup.js and rails by default decodes for params
    if params[:search_url].present?
      @back_to_search_results_url = params[:search_url]
    end
  end

end