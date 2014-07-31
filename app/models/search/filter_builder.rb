#ToDo Tests Needed
class FilterBuilder
  attr_accessor :filters, :filter_display_map

  def initialize
    @filters = build_filter_tree(get_filters)[0]
    @filter_display_map = @filters.build_map
  end

  def build_filter_tree(filters)
    filters = {filter: filters} unless filters[:filters].nil?
    filters.map do |key, value|
      value[:filters] = build_filter_tree(value[:filters]) unless value[:filters].nil?
      Filter.new(value)
    end
  end

  def get_filters
    #see mock for display types: https://jira.greatschools.org/secure/attachment/67270/GS_Filters_Delaware_Open_Filters_070914.jpg

    ### EXAMPLE ###
    {
      display_type: :blank_container,
      filters: {
        group1: { #group of filters in the view
          label: "Group of Filters",
          display_type: :title,
          filters: {
            label: 'A Dropdown',
            display_type: :collapsible_box,
            filters: {
              filter1: { label: 'Filter 1', display_type: :basic_checkbox, name: :checkbox_name, value: :checkbox_value},
              filter2: { label: 'Filter 2', display_type: :basic_checkbox, name: :checkbox_name, value: :checkbox_value},
              filter3: { label: 'Filter 3', display_type: :basic_checkbox, name: :checkbox_name, value: :checkbox_value}
            }
          }
        }
      }
    }

    {
      display_type: :blank_container,
      filters: {
        group1: {
          display_type: :filter_column_primary,
          filters: {
            distance: {
              label: 'Distance',
              display_type: :title,
              name: :distance,
              filters: {
                select_box: {
                  display_type: :select_box,
                  name: :distance,
                  filters: {
                     :default => {label: 'Select Miles', display_type: :select_box_value, name: :distance, value: nil},
                     1 => {label: '1 Mile', display_type: :select_box_value, name: :distance, value: 1},
                     2 => {label: '2 Miles', display_type: :select_box_value, name: :distance, value: 2},
                     3 => {label: '3 Miles', display_type: :select_box_value, name: :distance, value: 3},
                     4 => {label: '4 Miles', display_type: :select_box_value, name: :distance, value: 4},
                     5 => {label: '5 Miles', display_type: :select_box_value, name: :distance, value: 5},
                     10 => {label: '10 Miles', display_type: :select_box_value, name: :distance, value: 10},
                     15 => {label: '15 Miles', display_type: :select_box_value, name: :distance, value: 15},
                     20 => {label: '20 Miles', display_type: :select_box_value, name: :distance, value: 20},
                     25 => {label: '25 Miles', display_type: :select_box_value, name: :distance, value: 25},
                     30 => {label: '30 Miles', display_type: :select_box_value, name: :distance, value: 30},
                     60 => {label: '60 Miles', display_type: :select_box_value, name: :distance, value: 60}
                  }
                }
              }
            },
            st: {
              label: 'School Types',
              display_type: :title,
              name: :st,
              filters: {
                public: {label: 'Public Schools', display_type: :basic_checkbox, name: :st, value: :public},
                private: {label: 'Private Schools', display_type: :basic_checkbox, name: :st, value: :private},
                charter: {label: 'Charter Schools', display_type: :basic_checkbox, name: :st, value: :charter}
              }
            },
            transportation: {
              label: 'Transportation',
              display_type: :title,
              name: :transportation,
              filters: {
                povided_transit: {label: 'District provided', display_type: :basic_checkbox, name: :transportation, value: :provided_transit},
                public_transit: {label: 'Accessible via public transit', display_type: :basic_checkbox, name: :transportation, value: :public_transit}
              }
            },
            beforeAfterCare: {
              label: 'Care',
              display_type: :title,
              name: :beforeAfterCare,
              filters: {
                before: {label: 'Before School Care', display_type: :basic_checkbox, name: :beforeAfterCare, value: :before},
                after: {label: 'After School Care', display_type: :basic_checkbox, name: :beforeAfterCare, value: :after}
              }
            }
          }
        },
        group2: {
          display_type: :filter_column_secondary,
          filters: {
            dress_code: {
              label: 'Dress Code',
              display_type: :title,
              name: :dress_code,
              filters: {
                dress_code: {label: 'Dress Code', display_type: :basic_checkbox, name: :dress_code, value: :dress_code},
                uniform: {label: 'Uniform', display_type: :basic_checkbox, name: :dress_code, value: :uniform},
                no_dress_code: {label: 'No dress code', display_type: :basic_checkbox, name: :dress_code, value: :no_dress_code}
              }
            },
            class_offerings: {
              label: 'Class Offerings',
              display_type: :title,
              name: :class_offerings,
              filters: {
                ap: {label: 'AP Courses', display_type: :basic_checkbox, name: :class_offerings, value: :ap},
                performance_arts: {label: 'Performance Arts', display_type: :basic_checkbox, name: :class_offerings, value: :performance_arts},
                visual_media_arts: {label: 'Visual/Media Arts', display_type: :basic_checkbox, name: :class_offerings, value: :visual_media_arts},
                music: {label: 'Music', display_type: :basic_checkbox, name: :class_offerings, value: :music},
                world_languages: {
                  label: 'World Languages',
                  name: :world_languages,
                  display_type: :collapsible_box,
                  filters: {
                    french: {label: 'French', display_type: :basic_checkbox, name: :class_offerings, value: :french},
                    german: {label: 'German', display_type: :basic_checkbox, name: :class_offerings, value: :german},
                    spanish: {label: 'Spanish', display_type: :basic_checkbox, name: :class_offerings, value: :spanish},
                    mandarin: {label: 'Mandarin', display_type: :basic_checkbox, name: :class_offerings, value: :mandarin}
                  }
                }
              }
            },
            sports: {
              label: 'Sports',
              display_type: :blank_container, #Replace this with new clickable icon styling
              filters: {
                boys_sports: {
                  label: 'Boys Sports',
                  display_type: :title,
                  name: :boys_sports,
                  filters: {
                    baseball: {label: 'Baseball', display_type: :basic_checkbox, name: :boys_sports, value: :baseball},
                    basketball: {label: 'Basketball', display_type: :basic_checkbox, name: :boys_sports, value: :basketball},
                    football: {label: 'Football', display_type: :basic_checkbox, name: :boys_sports, value: :football},
                    soccer: {label: 'Soccer', display_type: :basic_checkbox, name: :boys_sports, value: :soccer},
                    track: {label: 'Track', display_type: :basic_checkbox, name: :boys_sports, value: :track}
                  }
                },
                girls_sports: {
                  label: 'Girls Sports',
                  display_type: :title,
                  name: :girls_sports,
                  filters: {
                    cheerleading: {label: 'Cheerleading', display_type: :basic_checkbox, name: :girls_sports, value: :cheerleading},
                    basketball: {label: 'Basketball', display_type: :basic_checkbox, name: :girls_sports, value: :basketball},
                    volleyball: {label: 'Volleyball', display_type: :basic_checkbox, name: :girls_sports, value: :volleyball},
                    soccer: {label: 'Soccer', display_type: :basic_checkbox, name: :girls_sports, value: :soccer},
                    track: {label: 'Track', display_type: :basic_checkbox, name: :girls_sports, value: :track}
                  }
                }
              }
            }
          }
        },
        group3: {
          display_type: :filter_column_secondary,
          filters: {
            school_focus: {
              label: 'School Focus',
              display_type: :title,
              name: :school_focus,
              filters: {
                arts: {label: 'Art', display_type: :basic_checkbox, name: :school_focus, value: :arts},
                language_immersion: {
                  label: 'World Language Immersion',
                  name: :world_language_immersion,
                  display_type: :collapsible_box,
                  filters: {
                    french: {label: 'French', display_type: :basic_checkbox, name: :school_focus, value: :french},
                    german: {label: 'German', display_type: :basic_checkbox, name: :school_focus, value: :german},
                    spanish: {label: 'Spanish', display_type: :basic_checkbox, name: :school_focus, value: :spanish},
                    mandarin: {label: 'Mandarin', display_type: :basic_checkbox, name: :school_focus, value: :mandarin}
                  }
                },
                science_tech: {label: 'Science/Tech (STEM)', display_type: :basic_checkbox, name: :school_focus, value: :science_tech},
                career_tech: {label: 'Career & Tech', display_type: :basic_checkbox, name: :school_focus, value: :career_tech},
                montessori: {label: 'Montessori', display_type: :basic_checkbox, name: :school_focus, value: :montessori},
                ib: {label: 'International Baccalaureate', display_type: :basic_checkbox, name: :school_focus, value: :ib},
                is: {label: 'Independent Study', display_type: :basic_checkbox, name: :school_focus, value: :is},
                college_focus: {label: 'College Focus', display_type: :basic_checkbox, name: :school_focus, value: :college_focus},
                waldorf: {label: 'Waldorf', display_type: :basic_checkbox, name: :school_focus, value: :waldorf},
                project: {label: 'Project-based Learning', display_type: :basic_checkbox, name: :school_focus, value: :project},
                online: {label: 'Online Learning', display_type: :basic_checkbox, name: :school_focus, value: :online}
              }
            }
          }
        }
      }
    }
  end
end