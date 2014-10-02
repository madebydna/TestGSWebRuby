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
    @great_schools_ratings = [OVERALL_RATING_NAME]
    @non_great_schools_ratings = []
    @schools.each do |school|
      @great_schools_ratings += ratings_types(school.school_cache.formatted_greatschools_ratings)
      @non_great_schools_ratings += ratings_types(school.school_cache.formatted_non_greatschools_ratings)
    end
    @great_schools_ratings.uniq!
    @non_great_schools_ratings.uniq!
  end

  def ratings_types(formatted_ratings)
    rating_types = []
    formatted_ratings.each do |rating_name, rating_value|
      next if rating_value == CachedRatingsMethods::NO_RATING_TEXT
      unless rating_types.include? rating_name
        rating_types << rating_name
      end
    end
    rating_types
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
    filter_display_map = FilterBuilder.new(@state).filter_display_map # for labeling fit score breakdowns
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
                    { display_type: 'quality/ratings', opt: { ratings_type: 'GreatSchools Rating' } },
                    { display_type: 'quality/ratings', opt: { ratings_type: 'Local Ratings' } },
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

  def set_back_to_search_results_instance_variable
    #search_url parameter is encoded in compare_schools_popup.js and rails by default decodes for params
    if params[:search_url].present?
      @back_to_search_results_url = params[:search_url]
    end
  end

end