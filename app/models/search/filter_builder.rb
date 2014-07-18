#ToDo Tests Needed
class FilterBuilder
  attr_accessor :filters, :filter_display_map

  def initialize
    @filters = build_filter(get_filters)
    @filter_display_map = build_filter_display_map(@filters)
  end

  def build_filter_tree(filters)
    filters.map { |key, value| build_filter(value)}
  end

  def build_filter(filters)
    filters = {filter: filters} unless filters[:filters].nil?
    filters.map do |key, value|
      value[:filters] = build_filter(value[:filters]) unless value[:filters].nil?
      Filter.new(value)
    end
  end

  def build_filter_display_map(filters)
    filters.inject({}) { |map,filter| map.merge!(filter.filters_display_map) }
  end

  def get_filters
    #see mock for display types: https://jira.greatschools.org/secure/attachment/67270/GS_Filters_Delaware_Open_Filters_070914.jpg

    ### EXAMPLE ###
    {
      group1: { #group of filters in the view
        name: "Group of Filters",
        display_type: :title,
        filters: {
          name: 'A Dropdown',
          display_type: :drop_down_level_1,
          filters: {
            name: 'Another Dropdown',
            display_type: :drop_down_level_2,
            filters: {
              display_type: :blank_container,
              key: :programs,
              filters: {
                filter1: { name: 'Filter 1', display_type: :basic_checkbox, category: :st, key: :filter1},
                filter2: { name: 'Filter 2', display_type: :basic_checkbox, category: :st, key: :filter2},
                filter3: { name: 'Filter 3', display_type: :basic_checkbox, category: :st, key: :filter3}
              }
            }
          }
        }
      }
    }

    {
      st: {
        name: 'School Types',
        display_type: :title,
        filters: {
          public: {name: 'Public Schools', display_type: :basic_checkbox, category: :st, key: :public},
          private: {name: 'Private Schools', display_type: :basic_checkbox, category: :st, key: :private},
          charter: {name: 'Charter Schools', display_type: :basic_checkbox, category: :st, key: :charter}
        }
      },
      beforeAfterCare: {
        name: 'Child Care Programs',
        display_type: :title,
        filters: {
          before: {name: 'Before School Care', display_type: :basic_checkbox, category: :beforeAfterCare, key: :before},
          after: {name: 'After School Care', display_type: :basic_checkbox, category: :beforeAfterCare, key: :after}
          }
      },
      dress_code: {
        name: 'Dress Code',
        display_type: :title,
        filters: {
          dress_code: {name: 'Dress Code', display_type: :basic_checkbox, category: :dress_code, key: :dress_code},
          uniform: {name: 'Uniform', display_type: :basic_checkbox, category: :dress_code, key: :uniform},
          no_dress_code: {name: 'No dress code', display_type: :basic_checkbox, category: :dress_code, key: :no_dress_code}
          }
      },
      transportation: {
        name: 'Transportation',
        display_type: :title,
        filters: {
          public_transit: {name: 'Accessible via public transit', display_type: :basic_checkbox, category: :transportation, key: :public_transit},
          ovided_transit: {name: 'District/school provided busses', display_type: :basic_checkbox, category: :transportation, key: :provided_transit}
          }
      },
      boys_sports: {
        name: 'Boys Sports',
        display_type: :title,
        filters: {
          baseball: {name: 'Baseball', display_type: :basic_checkbox, category: :boys_sports, key: :baseball},
          basketball: {name: 'Basketball', display_type: :basic_checkbox, category: :boys_sports, key: :basketball},
          football: {name: 'Football', display_type: :basic_checkbox, category: :boys_sports, key: :football},
          soccer: {name: 'Soccer', display_type: :basic_checkbox, category: :boys_sports, key: :soccer},
          track: {name: 'Track', display_type: :basic_checkbox, category: :boys_sports, key: :track}
        }
      },
      girls_sports: {
        name: 'Girls Sports',
        display_type: :title,
        filters: {
          cheerleading: {name: 'Cheerleading', display_type: :basic_checkbox, category: :girls_sports, key: :cheerleading},
          basketball: {name: 'Basketball', display_type: :basic_checkbox, category: :girls_sports, key: :basketball},
          volleyball: {name: 'Volleyball', display_type: :basic_checkbox, category: :girls_sports, key: :volleyball},
          soccer: {name: 'Soccer', display_type: :basic_checkbox, category: :girls_sports, key: :soccer},
          track: {name: 'Track', display_type: :basic_checkbox, category: :girls_sports, key: :track}
        }
      },
      class_offerings: {
        name: 'Class Offerings',
        display_type: :title,
        filters: {
          ap: {name: 'AP Courses', display_type: :basic_checkbox, category: :class_offerings, key: :ap},
          performance_arts: {name: 'Performance Art', display_type: :basic_checkbox, category: :class_offerings, key: :performance_arts},
          visual_media_arts: {name: 'Career & Tech', display_type: :basic_checkbox, category: :class_offerings, key: :visual_media_arts},
          music: {name: 'Montessori', display_type: :basic_checkbox, category: :class_offerings, key: :music},
          world_languages: {
            name: 'World Languages (dropdown)',
            key: :world_languages,
            display_type: :collapsible_box,
            filters: {
              french: {name: 'French', display_type: :basic_checkbox, category: :class_offerings, key: :french},
              german: {name: 'German', display_type: :basic_checkbox, category: :class_offerings, key: :german},
              spanish: {name: 'Spanish', display_type: :basic_checkbox, category: :class_offerings, key: :spanish},
              mandarin: {name: 'Mandarin', display_type: :basic_checkbox, category: :class_offerings, key: :mandarin}
            }
          }
          }
      },
      school_focus: {
        name: 'School Focus',
        display_type: :title,
        filters: {
          arts: {name: 'Art', display_type: :basic_checkbox, category: :school_focus, key: :arts},
          language_immersion: {
            name: 'World Language Immersion (dropdown)',
            key: :world_language_immersion,
            display_type: :collapsible_box,
            filters: {
              french: {name: 'French', display_type: :basic_checkbox, category: :school_focus, key: :french},
              german: {name: 'German', display_type: :basic_checkbox, category: :school_focus, key: :german},
              spanish: {name: 'Spanish', display_type: :basic_checkbox, category: :school_focus, key: :spanish},
              mandarin: {name: 'Mandarin', display_type: :basic_checkbox, category: :school_focus, key: :mandarin}
            }
          },
          science_tech: {name: 'Science/Tech (STEM)', display_type: :basic_checkbox, category: :school_focus, key: :science_tech},
          career_tech: {name: 'Career & Tech', display_type: :basic_checkbox, category: :school_focus, key: :career_tech},
          montessori: {name: 'Montessori', display_type: :basic_checkbox, category: :school_focus, key: :montessori},
          ib: {name: 'International Baccalaureate', display_type: :basic_checkbox, category: :school_focus, key: :ib},
          is: {name: 'Independent Study', display_type: :basic_checkbox, category: :school_focus, key: :is},
          college_focus: {name: 'College Focus', display_type: :basic_checkbox, category: :school_focus, key: :college_focus},
          waldorf: {name: 'Waldorf', display_type: :basic_checkbox, category: :school_focus, key: :waldorf},
          project: {name: 'Project-based Learning', display_type: :basic_checkbox, category: :school_focus, key: :project},
          online: {name: 'Online Learning', display_type: :basic_checkbox, category: :school_focus, key: :online}
        }
      },
      grades: {
        name: 'Grades',
        display_type: :title,
        key: :grades,
        filters: {
          :p => {name: 'Pre-School', display_type: :basic_checkbox, category: :grades, key: :p},
          :k => {name: 'Kindergarten', display_type: :basic_checkbox, category: :grades, key: :k},
          1 => {name: '1st Grade', display_type: :basic_checkbox, category: :grades, key: 1},
          2 => {name: '2nd Grade', display_type: :basic_checkbox, category: :grades, key: 2},
          3 => {name: '3rd Grade', display_type: :basic_checkbox, category: :grades, key: 3},
          4 => {name: '4th Grade', display_type: :basic_checkbox, category: :grades, key: 4},
          5 => {name: '5th Grade', display_type: :basic_checkbox, category: :grades, key: 5},
          6 => {name: '6th Grade', display_type: :basic_checkbox, category: :grades, key: 6},
          7 => {name: '7th Grade', display_type: :basic_checkbox, category: :grades, key: 7},
          8 => {name: '8th Grade', display_type: :basic_checkbox, category: :grades, key: 8},
          9 => {name: '9th Grade', display_type: :basic_checkbox, category: :grades, key: 9},
          10 => {name: '10th Grade', display_type: :basic_checkbox, category: :grades, key: 10},
          11 => {name: '11th Grade', display_type: :basic_checkbox, category: :grades, key: 11},
          12 => {name: '12th Grade', display_type: :basic_checkbox, category: :grades, key: 12}
        }
      }
    }
  end
end