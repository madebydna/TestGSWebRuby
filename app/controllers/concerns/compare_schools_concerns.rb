module CompareSchoolsConcerns
  extend ActiveSupport::Concern

  SCHOOL_CACHE_KEYS = %w(characteristics ratings test_scores esp_responses reviews_snapshot)

  def prep_school_ethnicity_data!
    all_breakdowns = []
    @schools.each do |school|
      school.ethnicity_data.each do |ethnicity|
        unless all_breakdowns.any? { |eth| eth == ethnicity['breakdown'] }
          all_breakdowns << ethnicity['breakdown']
        end
      end
    end
    @schools.each do |school|
      all_breakdowns.each do |breakdown|
        unless school.ethnicity_data.any? { |ethnicity| ethnicity['breakdown'] == breakdown }
          school.ethnicity_data << { 'breakdown' => breakdown, 'school_value' => nil }
        end
      end
    end
  end

  def decorated_schools
    decorated_schools = []
    cache_data = school_cache_data
    db_schools = School.on_db(@state).where(id: @params_schools, active: true)
    db_schools.each do |db_school|
      if decorated_schools.size < 4
        decorated_schools << SchoolCompareDecorator.new(db_school, context: cache_data[db_school.id.to_i])
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
                            datapoints: [
                                {method: :great_schools_rating_icon, label: 'GreatSchools rating'},
                                {method: :test_scores_rating, label: 'Test scores rating'},
                                {method: :student_growth_rating, label: 'Student growth rating'},
                            ]
                        }
                    },
                    { display_type: 'quality/rating' },
                    { display_type: 'quality/college_readiness' },
                    { display_type: 'quality/add_to_my_schools_list' }
                ]
            },
            {
                display_type: 'category',
                opt: {
                    subtitle: 'Fit Criteria',
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
                                {method: :students_enrolled, label: 'Students enrolled', icon: 'i-16-blue-students-enrolled'},
                                {method: :transportation, label: 'Transportation', icon: 'i-16-blue-transportation'},
                                {method: :before_care, label: 'Before care', icon: 'i-16-blue-before-care'},
                                {method: :after_school, label: 'After school', icon: 'i-16-blue-after-school'}
                            ]
                        }
                    },
                    { display_type: 'section_dividing_bar' },
                    { display_type: 'label', opt: { label: 'Programs'} },
                    {
                        display_type: 'line_data',
                        opt: {
                            datapoints: [
                                {method: :world_languages, label: 'World language', icon: 'i-16-blue-world-languages'},
                                {method: :clubs, label: 'Clubs', icon: 'i-16-blue-clubs'},
                                {method: :sports, label: 'Sports', icon: 'i-16-blue-sports-trophy'},
                                {method: :arts_and_music, label: 'Arts & Music', icon: 'i-16-blue-arts-and-music'}
                            ]
                        }
                    },
                    { display_type: 'section_dividing_bar' },
                    { display_type: 'label', opt: { label: 'Student Diversity'} },
                    { display_type: 'details/compare_pie_chart' },
                ]
            },
        ]
    }

  end

end