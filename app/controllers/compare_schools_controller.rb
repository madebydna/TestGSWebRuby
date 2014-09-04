class CompareSchoolsController < ApplicationController
  include GoogleMapConcerns

  SCHOOL_CACHE_KEYS = %w(characteristics ratings test_scores esp_responses reviews_snapshot)
  def show
    @school_compare_config = SchoolCompareConfig.new(compare_schools_list_mapping)

    @schools = []
    if params[:school_ids]
      @params_schools = params[:school_ids].split(',').uniq
      @state = :de
      @cache_data = cache_data
      @params_schools.each do |id|
        if @schools.size < 4
          begin
            school = School.on_db(@state).find(id)
            next unless school.active == 1
            @schools << SchoolCompareDecorator.new(school, context: @cache_data[id.to_i])
          rescue
            Rails.logger.error "Compare: no school found in state #{@state} with id #{id}"
          end
        end
      end
    end
    gon.pagename = 'CompareSchoolsPage'

    @map_schools = @schools

    mapping_points_through_gon_from_db
    assign_sprite_files_though_gon
  end

  def cache_data
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
                          {datapoint: :great_schools_rating_icon, label: 'GreatSchools rating'},
                          {datapoint: :test_scores_rating, label: 'Test scores rating'},
                          {datapoint: :student_growth_rating, label: 'Student growth rating'},
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
          }
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
                    {datapoint: :students_enrolled, label: 'Students enrolled', icon: 'i-16-blue-students-enrolled'},
                    {datapoint: :transportation, label: 'Transportation', icon: 'i-16-blue-transportation'},
                    {datapoint: :before_care, label: 'Before care', icon: 'i-16-blue-before-care'},
                    {datapoint: :after_school, label: 'After school', icon: 'i-16-blue-after-school'}
                ]
              }
            },
            { display_type: 'section_dividing_bar' },
            { display_type: 'label', opt: { label: 'Programs'} },
            {
              display_type: 'line_data',
              opt: {
                datapoints: [
                    {datapoint: :world_languages, label: 'World language', icon: 'i-16-blue-world-languages'},
                    {datapoint: :clubs, label: 'Clubs', icon: 'i-16-blue-clubs'},
                    {datapoint: :sports, label: 'Sports', icon: 'i-16-blue-sports-trophy'},
                    {datapoint: :arts_and_music, label: 'Arts & Music', icon: 'i-16-blue-arts-and-music'}
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