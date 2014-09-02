class CompareSchoolsController < ApplicationController

  SCHOOL_CACHE_KEYS = %w(characteristics ratings test_scores esp_responses reviews_snapshot)
  def show

    @schools = School.on_db(:de).find(14), School.on_db(:de).find(4), School.on_db(:de).find(6)
    @school_compare_config = SchoolCompareConfig.new(compare_schools_list_mapping)
    @cache_data = cache_data

  end

  def cache_data
    SchoolCache.for_schools_keys(SCHOOL_CACHE_KEYS,[4,14,6],'DE')
  end

  def compare_schools_list_mapping
    #ToDo If any module needs to be more data-base driven, you can add further levels into the hash
    #ToDo ex. currently display_type rating and college_readiness are just individually hard-coded partials. If needed, you can add more nesting/partials for more customizability
    {
      display_type: 'school',
      children: [
        { display_type: 'header' },
        {
          display_type: 'blank_container',
          children: [
            {
              display_type: 'subtitle',
              opt: {
                label: 'Quality'
              }
            },
            { display_type: 'quality/rating' },
            { display_type: 'quality/college_readiness' },
            { display_type: 'quality/add_to_my_schools_list' }
          ]
        },
        {
          display_type: 'blank_container',
          children: [
            {
              display_type: 'subtitle',
              opt: {
                label: 'Fit Criteria'
              }
            }
          ]
        },
        {
          display_type: 'blank_container',
          children: [
            {
              display_type: 'subtitle',
              opt: {
                label: 'Reviews'
              }
            }
          ]
        },
        {
          display_type: 'blank_container',
          children: [
            {
              display_type: 'subtitle',
              opt: {
                label: 'Details'
              }
            },
            # { display_type: 'details/compare_pie_chart' },
            {
                display_type: 'details/at_a_glance',
                opt: {
                    label: 'At a glance',
                    datapoints: [:students_enrolled, :transportation, :before_care, :after_school]
                }
            },
            { display_type: 'section_dividing_bar' },
          ]
        },
      ]
    }

  end

end