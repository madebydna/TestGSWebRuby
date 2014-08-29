class CompareSchoolsController < ApplicationController

  def show

    @schools = School.on_db(:ca).find(1), School.on_db(:ca).find(2), School.on_db(:ca).find(3)
    @school_compare_config = SchoolCompareConfig.new(compare_schools_list_mapping)

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
        }
      ]
    }

  end

end