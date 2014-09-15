module CompareSchoolsConcerns
  extend ActiveSupport::Concern

  SCHOOL_CACHE_KEYS = %w(characteristics ratings test_scores esp_responses reviews_snapshot)
  OVERALL_RATING_NAME = 'GreatSchools rating'
  COMPARE_RATING_TYPES = {'GreatSchools rating' => 1, 'Test score rating' => 2, 'Student growth rating' => 3, 'College readiness rating' => 4}

  def prep_school_ethnicity_data!
    all_breakdowns = []
    @ethnicity_datapoints = []
    @schools.each do |school|
      school.ethnicity_data.each do |ethnicity|
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
        school_ethnicity = school.ethnicity_data.find { |ethnicity| ethnicity['breakdown'] == breakdown }
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
      school.ratings.each do |rating|
        unless all_ratings.any? { |r| r == rating['name'] }
          all_ratings << rating['name']
        end
      end
    end
    @schools.each do |school|
      school.prepped_ratings = {}
      all_ratings.each do |rating_name|
        school_rating = school.ratings.find{ |r| r['name'] == rating_name }
        school_value = school_rating.nil? ? nil : school_rating['school_value_float']
        school.prepped_ratings = school.prepped_ratings.merge(rating_name => school_value)

        unless @ratings_datapoints.any? { |datapoint| datapoint[:label] == rating_name }
          if rating_name == OVERALL_RATING_NAME
            @ratings_datapoints << { method: :great_schools_rating_icon, argument: rating_name, label: rating_name}
          elsif COMPARE_RATING_TYPES.key? rating_name
            @ratings_datapoints << { method: :school_rating_by_name, argument: rating_name, label: rating_name}
          end
        end
      end
    end
    prep_ratings_display!
  end

  def decorated_schools
    decorated_schools = []
    cache_data = school_cache_data
    db_schools = School.on_db(@state).where(id: @params_schools, active: true)
    db_schools.each do |db_school|
      if decorated_schools.size < 4
        decorated_school = SchoolCompareDecorator.new(db_school, context: cache_data[db_school.id.to_i])
        decorated_school.calculate_fit_score!({})
        decorated_schools << decorated_school
      end
    end
    decorated_schools
  end

  def school_cache_data
    SchoolCache.for_schools_keys(SCHOOL_CACHE_KEYS,@params_schools,@state)
  end

  def compare_schools_list_mapping
    #ToDo If any module needs to be more data-base driven, you can add further levels into the hash
    #ToDo ex. currently display_type rating and college_readiness are just individually hard-coded partials. If needed, you can add more nesting/partials for more customizability
    {
        display_type: 'school',
        children: [
            { display_type: 'header' },
            {
                display_type: 'category',
                opt: {
                    subtitle: 'Quality',
                    key: :quality
                },
                children: [
                    { display_type: 'label', opt: { label: 'Rating'} },
                    {
                        display_type: 'line_data',
                        opt: {
                            datapoints: @ratings_datapoints
                        }
                    }
                ]
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
                        display_type: 'line_data',
                        opt: {
                            table_name: 'js-comparePieChartTable',
                            datapoints: @ethnicity_datapoints
                        }
                    }
                ]
            },
            {
                display_type: 'buttons',
                opt: {
                    datapoints:[
                      {method: :school_page_path, label: 'View full profile', class: 'btn btn-primary tac clearfix'},
                      {method: :zillow_formatted_url, label: 'Homes for sale', icon: 'iconx16 i-16-home ', class: 'btn btn-default tal clearfix' ,target: '_blank'},
                    ]
                }
            },
        ]
    }

  end

  protected

  def prep_ratings_display!
    overall_rating = @ratings_datapoints.find { |datapoint| datapoint[:label] == OVERALL_RATING_NAME }
    if overall_rating
      @ratings_datapoints -= [overall_rating]
      @ratings_datapoints.sort_by! { |datapoint| COMPARE_RATING_TYPES[datapoint[:label]] }
      @ratings_datapoints = [overall_rating] + @ratings_datapoints
    elsif @ratings_datapoints.empty?
      @ratings_datapoints = [{ method: :great_schools_rating_icon, label: OVERALL_RATING_NAME}]
    else
      @ratings_datapoints.sort_by! { |datapoint| COMPARE_RATING_TYPES[datapoint[:label]] }
      @ratings_datapoints = [{ method: :great_schools_rating_icon, label: OVERALL_RATING_NAME}] + @ratings_datapoints
    end
  end
end