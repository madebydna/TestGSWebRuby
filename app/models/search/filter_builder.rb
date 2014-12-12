#ToDo Tests Needed
class FilterBuilder
  attr_accessor :filters, :filter_display_map

  # Watch out!
  # If you change FilterBuilder's behavior, ensure that you don't need to change cache_key. Ask, if you don't know.

  def initialize(state = '', city = '', force_simple_filters = false)
    @state = state.to_s.downcase
    @city = city.to_s.downcase
    @force_simple_filters = force_simple_filters
    @filters = build_filter_tree_for(@state, @city)
    @filter_display_map = @filters.build_map
  end

  def build_filter_tree_for(state, city)
    @callbacks = @force_simple_filters ? [] : build_callbacks(get_callbacks_for_location(state, city))
    base_filters = base_filter_set_for(state, city)
    build_filter_tree({filter: base_filters})[0]
  end

  def build_filter_tree(filters)
    filters.map do |key, filter|
      build_filter(run_db_callbacks(filter))
    end.compact
  end

  def build_filter(filter)
    filter[:filters] = build_filter_tree(filter[:filters]) if filter[:filters].present?
    Filter.new(filter) if filter.present?
  end

  def run_db_callbacks(filter)
    begin
      @callbacks.each_with_index do |callback, i|
        callback_value = callback.call(filter)
        (@callbacks.delete_at(i) and return callback_value) if callback_value
      end
    rescue Exception => e
      Rails.logger.warn "Error: #{e}. Additional Custom Filter Not applied"
      @callbacks = [] #delete callbacks
    else
      filter
    end
  end

  def build_callbacks(db_callbacks)
    if db_callbacks
      db_callbacks.map do |callback|
        try("build_#{callback[:callback_type]}_callback".to_sym, callback[:conditions], callback[:options])
      end.compact
    else
      []
    end
  end

  def get_callbacks_for_location(state, city)
    city_callbacks[state][city] || state_callbacks[state]
  end

  def state_callbacks
    Hash.new([]).merge(
        {
            in: add_vouchers_callbacks,
            de: []
        }
    ).stringify_keys!
  end

  def city_callbacks
    Hash.new{ |h,k| h[k] = {} }.merge(
        {
            mi: {
                detroit: detroit_mi_callbacks
            }.stringify_keys!,
            wi: {
                milwaukee: add_vouchers_callbacks
            }.stringify_keys!
        }
    ).stringify_keys!
  end

  def build_append_to_children_callback(conditions, new_filter)
    lambda do |filter|
      conditions.each do |condition|
        return false if filter[condition[:key].to_sym].to_s != condition[:match]
      end
      filter[:filters].present? ? (filter[:filters].merge!(new_filter) and filter) : new_filter #ToDo add string decoding when we pull hashes from db
    end
  end

  def build_insert_after_callback(conditions, new_filter)
    lambda do |filter|
      if filter[:filters].present?
        matching_index = -1
        filter[:filters].each_with_index do |(_, child_filter), index|
          all_conditions_match = true
          conditions.each do |condition|
            all_conditions_match &&= (child_filter[condition[:key].to_sym].to_s == condition[:match])
          end
          matching_index = index if all_conditions_match
        end
        return false if matching_index == -1
        hash_as_array = filter[:filters].to_a
        new_filter.each do |k,v|
          hash_as_array.insert(matching_index+1, [k, v])
          matching_index += 1
        end
        filter[:filters] = Hash[ hash_as_array ]
        filter
      else
        false
      end
    end
  end

  def build_cache_key_callback(_, options)
    lambda do |filter|
      return false unless filter.has_key?(:cache_key)
      filter[:cache_key] = "#{options[:value]}_v#{options[:version] || '1'}"
      filter
    end
  end

  def add_vouchers_callbacks
    [
      {
        callback_type: 'cache_key',
        options: {
          value: 'vouchers',
          version: 1
        }
      },
      {conditions: [{key: 'name', match: 'group3'},{key: 'display_type', match: 'filter_column_secondary'}], callback_type: 'append_to_children', options:
        {
          enrollment: {
            label: 'Enrollment', display_type: :title, name: :enrollment, filters: {
              filter1: { label: 'Accepts vouchers (private schools only)', display_type: :basic_checkbox, name: :enrollment, value: :vouchers }
            }
          }
        }
      }
    ]
  end

  def detroit_mi_callbacks
    [
        {
          callback_type: 'cache_key',
          options: {
            value: 'college_readiness',
            version: 2
          }
        },
        {
            conditions:
                [
                    {key: 'name', match: 'st'}, {key: 'display_type', match: 'title'}
                ],
            callback_type: 'insert_after',
            options:
                {
                    cgr: {
                        label: 'College Readiness', display_type: :title, name: :cgr, filters: {
                            filter1: { label: '70% or more attend college', display_type: :basic_checkbox, name: :cgr, value: '70_TO_100' }
                        }
                    }
                }
        }
    ]
  end

  def include_advanced_filters?(state, city)
    state_callbacks.key?(state) || city_callbacks[state].key?(city)
  end

  def base_filter_set_for(state, city)
    if include_advanced_filters?(state, city) && !@force_simple_filters
      default_advanced_filters
    else
      default_simple_filters
    end
  end

  def default_simple_filters
    {
        cache_key: 'simple_v1',
        display_type: :blank_container,
        filters: {
            group1: {
                display_type: :filter_column_primary,
                filters: default_simple_filters_hash
            }
        }
    }
  end

  def default_simple_filters_hash
    {
      grade: {
        label: 'Grade Level',
        display_type: :title,
        name: :grades,
        filters: {
          select_box: {
            display_type: :select_box,
            name: :grades,
            filters: {
              :default => {label: 'Select Grade', display_type: :select_box_value, name: :grades, value: nil},
              :p => {label: 'Pre-School', display_type: :select_box_value, name: :grades, value: :p},
              :k => {label: 'Kindergarten', display_type: :select_box_value, name: :grades, value: :k},
              1 => {label: '1st Grade', display_type: :select_box_value, name: :grades, value: 1},
              2 => {label: '2nd Grade', display_type: :select_box_value, name: :grades, value: 2},
              3 => {label: '3rd Grade', display_type: :select_box_value, name: :grades, value: 3},
              4 => {label: '4th Grade', display_type: :select_box_value, name: :grades, value: 4},
              5 => {label: '5th Grade', display_type: :select_box_value, name: :grades, value: 5},
              6 => {label: '6th Grade', display_type: :select_box_value, name: :grades, value: 6},
              7 => {label: '7th Grade', display_type: :select_box_value, name: :grades, value: 7},
              8 => {label: '8th Grade', display_type: :select_box_value, name: :grades, value: 8},
              9 => {label: '9th Grade', display_type: :select_box_value, name: :grades, value: 9},
              10 => {label: '10th Grade', display_type: :select_box_value, name: :grades, value: 10},
              11 => {label: '11th Grade', display_type: :select_box_value, name: :grades, value: 11},
              12 => {label: '12th Grade', display_type: :select_box_value, name: :grades, value: 12},
            }
          }
        }
      },
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
      }
    }
  end

  def default_advanced_filters
    #see mock for display types: https://jira.greatschools.org/secure/attachment/67270/GS_Filters_Delaware_Open_Filters_070914.jpg
    {
      cache_key: 'advanced_v1',
      display_type: :blank_container,
      filters: {
        group1: {
          display_type: :filter_column_primary,
          filters: default_simple_filters_hash.merge({
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
          })
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
          name: :group3,
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