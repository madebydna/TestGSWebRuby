#ToDo Tests Needed
class FilterBuilder
  attr_accessor :filters, :filter_display_map

  def initialize(state = '')
    @callbacks = build_callbacks(get_callbacks_from_db(state))
    @filters = build_filter_tree(get_filters)[0]
    @filter_display_map = @filters.build_map
  end

  def build_filter_tree(filters)
    filters = {filter: filters} unless filters[:filters].nil?
    array = []
    filters.each do |key, filter|
      if callback_filter = run_db_callbacks(filter)
        callback_filter[:filters] = build_filter_tree(callback_filter[:filters]) unless callback_filter[:filters].nil?
        array << Filter.new(callback_filter)
      end
      filter[:filters] = build_filter_tree(filter[:filters]) unless filter[:filters].nil?
      array << Filter.new(filter)
    end
    array
  end

  def run_db_callbacks(filter)
    @callbacks.each do |callback|
      return callback.call(filter) if callback.call(filter) #returns filter if callback matches conditional
    end
    false
  end

  def build_callbacks(db_callbacks)
    db_callbacks.map do |callback|
      keys = callback[:key].split(',')
      matches = callback[:match].split(',')
      conditions = []

      keys.each_with_index do |key, i|
        conditions << {key: key, match: matches[i]}
      end

      lambda do |filter|
        conditions.each do |condition|
          return false if filter[condition[:key].to_sym].to_s != condition[:match]
        end
        callback[:new_filter] #add string decoding when we pull hashes from db
      end
    end
  end

  def get_callbacks_from_db(state)
    if state.casecmp('in').zero?
      indiana_db_callbacks
    else
      []
    end
  end

  def indiana_db_callbacks
    [
      {key: 'name,value', match: 'distance,25', new_filter: { label: '22 Miles', display_type: :select_box_value, name: :distance, value: 22 } },
      {key: 'name,value', match: 'distance,60', new_filter:
        {
          display_type: :blank_container,
          filters: {
            fitler1: { label: '57 Miles', display_type: :select_box_value, name: :distance, value: 57 },
            filter2: { label: '58 Miles', display_type: :select_box_value, name: :distance, value: 58 }
          }
        }
      },
      {key: 'name,value', match: 'class_offerings,mandarin', new_filter: { label: 'Japanese', unique_label: 'Japanese (class)', display_type: :basic_checkbox, name: :class_offerings, value: :japanese } },
    ]
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
              label: 'Show schools within',
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
              label: 'School Type',
              display_type: :title,
              name: :st,
              filters: {
                public: {label: 'Public district schools', display_type: :basic_checkbox, name: :st, value: :public},
                charter: {label: 'Public charter schools', display_type: :basic_checkbox, name: :st, value: :charter},
                private: {label: 'Private schools', display_type: :basic_checkbox, name: :st, value: :private}
              }
            },
            transportation: {
              label: 'Transportation options',
              display_type: :title,
              name: :transportation,
              filters: {
                povided_transit: {label: 'District provided transit', display_type: :basic_checkbox, name: :transportation, value: :provided_transit},
                public_transit: {label: 'Near public transit', display_type: :basic_checkbox, name: :transportation, value: :public_transit}
              }
            },
            beforeAfterCare: {
              label: 'Before/After Care',
              display_type: :title,
              name: :beforeAfterCare,
              filters: {
                before: {label: 'Before school care', display_type: :basic_checkbox, name: :beforeAfterCare, value: :before},
                after: {label: 'After school care', display_type: :basic_checkbox, name: :beforeAfterCare, value: :after}
              }
            }
          }
        },
        group2: {
          display_type: :filter_column_secondary,
          filters: {
            dress_code: {
              label: 'Dress code',
              display_type: :title,
              name: :dress_code,
              filters: {
                dress_code: {label: 'Dress code', display_type: :basic_checkbox, name: :dress_code, value: :dress_code},
                uniform: {label: 'Uniform', display_type: :basic_checkbox, name: :dress_code, value: :uniform},
                no_dress_code: {label: 'No dress code', display_type: :basic_checkbox, name: :dress_code, value: :no_dress_code}
              }
            },
            class_offerings: {
              label: 'Class Offering',
              display_type: :title,
              name: :class_offerings,
              filters: {
                ap: {label: 'AP courses', display_type: :basic_checkbox, name: :class_offerings, value: :ap},
                music: {label: 'Music', display_type: :basic_checkbox, name: :class_offerings, value: :music},
                performance_arts: {label: 'Performance arts', display_type: :basic_checkbox, name: :class_offerings, value: :performance_arts},
                visual_media_arts: {label: 'Visual/Media arts', display_type: :basic_checkbox, name: :class_offerings, value: :visual_media_arts},
                world_languages: {
                  label: 'World languages',
                  name: :world_languages,
                  display_type: :collapsible_box,
                  filters: {
                    french: {label: 'French', unique_label: 'French (class)', display_type: :basic_checkbox, name: :class_offerings, value: :french},
                    german: {label: 'German', unique_label: 'German (class)', display_type: :basic_checkbox, name: :class_offerings, value: :german},
                    spanish: {label: 'Spanish', unique_label: 'Spanish (class)', display_type: :basic_checkbox, name: :class_offerings, value: :spanish},
                    mandarin: {label: 'Mandarin', unique_label: 'Mandarin (class)', display_type: :basic_checkbox, name: :class_offerings, value: :mandarin}
                  }
                }
              }
            },
            sports: {
              label: 'Sports',
              display_type: :title, #Replace this with new clickable icon styling
              name: [:boys_sports, :girls_sports],
              filters: {
                sports_icons: {
                  label: 'Sports',
                  display_type: :sports_gender_button,
                  filters: {
                    boys_sports: {
                      label: 'Boys Sports',
                      display_type: :sports_button_group,
                      name: :boys_sports,
                      filters: {
                        soccer: {label: 'Soccer', unique_label: 'Soccer (boys)', display_type: :sports_values, name: :boys_sports, value: :soccer},
                        track: {label: 'Track', unique_label: 'Track (boys)', display_type: :sports_values, name: :boys_sports, value: :track},
                        basketball: {label: 'Basketball', unique_label: 'Basketball (boys)', display_type: :sports_values, name: :boys_sports, value: :basketball},
                        football: {label: 'Football', unique_label: 'Football (boys)', display_type: :sports_values, name: :boys_sports, value: :football},
                        baseball: {label: 'Baseball', unique_label: 'Baseball (boys)', display_type: :sports_values, name: :boys_sports, value: :baseball}
                      }
                    },
                    girls_sports: {
                      label: 'Girls Sports',
                      display_type: :sports_button_group,
                      name: :girls_sports,
                      filters: {
                        soccer: {label: 'Soccer', unique_label: 'Soccer (girls)', display_type: :sports_values, name: :girls_sports, value: :soccer},
                        track: {label: 'Track', unique_label: 'Track (girls)', display_type: :sports_values, name: :girls_sports, value: :track},
                        volleyball: {label: 'Volleyball', unique_label: 'Volleyball (girls)', display_type: :sports_values, name: :girls_sports, value: :volleyball},
                        cheerleading: {label: 'Cheerleading', unique_label: 'Cheerleading (girls)', display_type: :sports_values, name: :girls_sports, value: :cheerleading},
                        basketball: {label: 'Basketball', unique_label: 'Basketball (girls)', display_type: :sports_values, name: :girls_sports, value: :basketball}
                      }
                    }
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
                arts: {label: 'Arts focus', display_type: :basic_checkbox, name: :school_focus, value: :arts},
                career_tech: {label: 'Career & technology', display_type: :basic_checkbox, name: :school_focus, value: :career_tech},
                college_focus: {label: 'College focus', display_type: :basic_checkbox, name: :school_focus, value: :college_focus},
                is: {label: 'Independent study', display_type: :basic_checkbox, name: :school_focus, value: :is},
                ib: {label: 'International Baccalaureate', display_type: :basic_checkbox, name: :school_focus, value: :ib},
                montessori: {label: 'Montessori', display_type: :basic_checkbox, name: :school_focus, value: :montessori},
                online: {label: 'Online learning', display_type: :basic_checkbox, name: :school_focus, value: :online},
                project: {label: 'Project-based learning', display_type: :basic_checkbox, name: :school_focus, value: :project},
                science_tech: {label: 'Science/Technology (STEM)', display_type: :basic_checkbox, name: :school_focus, value: :science_tech},
                waldorf: {label: 'Waldorf', display_type: :basic_checkbox, name: :school_focus, value: :waldorf},
                language_immersion: {
                  label: 'World language immersion',
                  name: :world_language_immersion,
                  display_type: :collapsible_box,
                  filters: {
                    french: {label: 'French', unique_label: 'French (immersion)', display_type: :basic_checkbox, name: :school_focus, value: :french},
                    german: {label: 'German', unique_label: 'German (immersion)', display_type: :basic_checkbox, name: :school_focus, value: :german},
                    spanish: {label: 'Spanish', unique_label: 'Spanish (immersion)', display_type: :basic_checkbox, name: :school_focus, value: :spanish},
                    mandarin: {label: 'Mandarin', unique_label: 'Mandarin (immersion)', display_type: :basic_checkbox, name: :school_focus, value: :mandarin}
                  }
                }
              }
            }
          }
        }
      }
    }
  end
end