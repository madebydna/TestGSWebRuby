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
            de: [],
            ga: [],
            ok: add_special_education_options_callbacks,
            oh: add_vouchers_callbacks_oh
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
            }.stringify_keys!,
            dc: {
                washington: add_vouchers_callbacks
            }.stringify_keys!,
            ca: {
                oakland: summer_programs_callbacks,
                'san francisco' => summer_programs_callbacks
            }.stringify_keys!,
            in: {
              indianapolis: indianapolis_callbacks,
            }.stringify_keys!,
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

  def indianapolis_callbacks
    [
      {
        callback_type: 'cache_key',
        options: {
          value: 'ptq_rating_vouchers',
          version: 1
        }
      },
      ptq_rating_callback,
      voucher_callback,
    ]
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
      voucher_callback
    ]
  end

  def add_vouchers_callbacks_oh
    [
        {
            callback_type: 'cache_key',
            options: {
                value: 'vouchers_oh',
                version: 1
            }
        },
        voucher_callback_oh
    ]
  end

  def voucher_callback_oh
    # Note that this callback is different than the rest because it needs to be combined
    # with another. Regular callbacks should all include a cache_key component.
    {
        conditions: [{key: 'name', match: 'group3'},{key: 'display_type', match: 'filter_column_secondary'}], callback_type: 'append_to_children', options:
        {
            enrollment: {
                label: t('Enrollment'), display_type: :title, name: :enrollment, filters: {
                    filter1: { label: t('Accepts vouchers (private schools only)'), display_type: :basic_checkbox, name: :enrollment, value: :vouchers },
                    filter2: { label: t('Cleveland scholarship'), display_type: :basic_checkbox, name: :voucher_type, value: :Cleveland },
                    filter3: { label: t('Special needs scholarship'), display_type: :basic_checkbox, name: :voucher_type, value: :Jon_Peterson_Special_Needs},
                    filter4: { label: t('Autism scholarship'), display_type: :basic_checkbox, name: :voucher_type, value: :Autism },
                    filter5: { label: t('EdChoice scholarship'), display_type: :basic_checkbox, name: :voucher_type, value: :EdChoice }

                }
            }
        }
    }
  end

  def voucher_callback
    # Note that this callback is different than the rest because it needs to be combined
    # with another. Regular callbacks should all include a cache_key component.
    {
      conditions: [{key: 'name', match: 'group3'},{key: 'display_type', match: 'filter_column_secondary'}], callback_type: 'append_to_children', options:
      {
        enrollment: {
          label: t('Enrollment'), display_type: :title, name: :enrollment, filters: {
            filter1: { label: t('Accepts vouchers (private schools only)'), display_type: :basic_checkbox, name: :enrollment, value: :vouchers }
          }
        }
      }
    }
  end

  def ptq_rating_callback
    # Note that this callback is different than the rest because it needs to be combined
    # with another. Regular callbacks should all include a cache_key component.
    {
      conditions:
      [
        {key: 'name', match: 'gs_rating'}
      ],
      callback_type: 'insert_after',
      options:
      {
        ptq_rating: {
          label: t('PTQ Rating (Preschool Only)'), display_type: :title, name: :ptq_rating, filters: {
            ptq1: { label: t('Level 1'), display_type: :basic_checkbox, name: :ptq_rating, value: :level_1 },
            ptq2: { label: t('Level 2'), display_type: :basic_checkbox, name: :ptq_rating, value: :level_2 },
            ptq3: { label: t('Level 3'), display_type: :basic_checkbox, name: :ptq_rating, value: :level_3 },
            ptq4: { label: t('Level 4'), display_type: :basic_checkbox, name: :ptq_rating, value: :level_4 },
          }
        }
      }
    }
  end

  def detroit_mi_callbacks
    [
      {
        callback_type: 'cache_key',
        options: {
          value: 'college_readiness_gstq_rating',
          version: 1
        }
      },
      college_readiness_gstq_callback,
      # gstq_rating_callback,
    ]
  end

  def college_readiness_gstq_callback
    {
      conditions:
      [
        {key: 'name', match: 'gs_rating'}
      ],
      callback_type: 'insert_after',
      options:
      {
        cgr: {
          label: t('College Readiness'),
          display_type: :title,
          name: :cgr,
          filters: {
            filter1: { label: t('70% or more attend college'), display_type: :basic_checkbox, name: :cgr, value: '70_TO_100' }
          }
        },
        gstq_rating: {
            label: t('Great Start to Quality (preschool only)'),
            display_type: :title,
            name: :gstq_rating,
            filters: {
              gstq5: { label: t('5 stars'), display_type: :basic_checkbox, name: :gstq_rating, value: :'5' },
              gstq4: { label: t('4 stars'), display_type: :basic_checkbox, name: :gstq_rating, value: :'4' },
              gstq3: { label: t('3 stars'), display_type: :basic_checkbox, name: :gstq_rating, value: :'3' },
              gstq2: { label: t('2 stars'), display_type: :basic_checkbox, name: :gstq_rating, value: :'2' },
              gstq1: { label: t('1 star'), display_type: :basic_checkbox, name: :gstq_rating, value: :'1' }
            }
        }
      }
    }
  end

  def summer_programs_callbacks
    [
        {
            callback_type: 'cache_key',
            options: {
                value: 'summer_programs',
                version: 1
            }
        },
        {
            conditions:
                [
                    {key: 'name', match: 'beforeAfterCare'}, {key: 'value', match: 'after'}
                ],
            callback_type: 'insert_after',
            options:
                {
                    summer: {label: t('Summer program'), display_type: :basic_checkbox, name: :summer_program, value: :yes}
                }
        }
    ]
  end

  def add_special_education_options_callbacks
    [
      {
        callback_type: 'cache_key',
        options: {
          value: 'special_education_options',
          version: 1
        }
      },
      {
        conditions: [{key: 'name', match: 'group3'},{key: 'display_type', match: 'filter_column_secondary'}], callback_type: 'append_to_children', options:
        {
          spec_ed: {
            label: t('Special education'), display_type: :title, name: :spec_ed, filters: {
              autism: { label: t('Autism'), display_type: :basic_checkbox, name: :spec_ed, value: :autism },
              deaf_blindness: { label: t('Deaf-blindness'), display_type: :basic_checkbox, name: :spec_ed, value: :deaf_blindness },
              deafness: { label: t('Deafness'), display_type: :basic_checkbox, name: :spec_ed, value: :deafness },
              developmental_delay: { label: t('Developmental delay'), display_type: :basic_checkbox, name: :spec_ed, value: :developmental_delay },
              emotional: { label: t('Emotional disturbance'), display_type: :basic_checkbox, name: :spec_ed, value: :emotional },
              hearing_impairments: { label: t('Hearing impairment'), display_type: :basic_checkbox, name: :spec_ed, value: :hearing_impairments },
              cognitive: { label: t('Intellectual disability'), display_type: :basic_checkbox, name: :spec_ed, value: :cognitive },
              multiple: { label: t('Multiple disabilities'), display_type: :basic_checkbox, name: :spec_ed, value: :multiple },
              orthopedic: { label: t('Orthopedic impairment'), display_type: :basic_checkbox, name: :spec_ed, value: :orthopedic },
              ld: { label: t('Specific learning disability'), display_type: :basic_checkbox, name: :spec_ed, value: :ld },
              speech: { label: t('Speech or language impairment'), display_type: :basic_checkbox, name: :spec_ed, value: :speech },
              brain_injury: { label: t('Traumatic brain injury'), display_type: :basic_checkbox, name: :spec_ed, value: :brain_injury },
              blindness: { label: t('Visual impairment, including blindness'), display_type: :basic_checkbox, name: :spec_ed, value: :blindness },
              other: { label: t('Other health impairment'), display_type: :basic_checkbox, name: :spec_ed, value: :other },
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
        label: t('Grade Level'),
        display_type: :title,
        name: :grades,
        filters: {
          select_box: {
            display_type: :select_box,
            name: :grades,
            filters: {
              :default => {label: t('Select Grade'), display_type: :select_box_value, name: :grades, value: nil},
              :p => {label: t('Preschool'), display_type: :select_box_value, name: :grades, value: :p},
              :k => {label: t('Kindergarten'), display_type: :select_box_value, name: :grades, value: :k},
              1 => {label: t('1st Grade'), display_type: :select_box_value, name: :grades, value: 1},
              2 => {label: t('2nd Grade'), display_type: :select_box_value, name: :grades, value: 2},
              3 => {label: t('3rd Grade'), display_type: :select_box_value, name: :grades, value: 3},
              4 => {label: t('4th Grade'), display_type: :select_box_value, name: :grades, value: 4},
              5 => {label: t('5th Grade'), display_type: :select_box_value, name: :grades, value: 5},
              6 => {label: t('6th Grade'), display_type: :select_box_value, name: :grades, value: 6},
              7 => {label: t('7th Grade'), display_type: :select_box_value, name: :grades, value: 7},
              8 => {label: t('8th Grade'), display_type: :select_box_value, name: :grades, value: 8},
              9 => {label: t('9th Grade'), display_type: :select_box_value, name: :grades, value: 9},
              10 => {label: t('10th Grade'), display_type: :select_box_value, name: :grades, value: 10},
              11 => {label: t('11th Grade'), display_type: :select_box_value, name: :grades, value: 11},
              12 => {label: t('12th Grade'), display_type: :select_box_value, name: :grades, value: 12},
            }
          }
        }
      },
      distance: {
        label: t('Show schools within'),
        display_type: :title,
        name: :distance,
        filters: {
          select_box: {
            display_type: :select_box,
            name: :distance,
            filters: {
              :default => {label: t('Select Miles'), display_type: :select_box_value, name: :distance, value: nil},
              1 => {label: t('1 Mile'), display_type: :select_box_value, name: :distance, value: 1},
              2 => {label: t('2 Miles'), display_type: :select_box_value, name: :distance, value: 2},
              3 => {label: t('3 Miles'), display_type: :select_box_value, name: :distance, value: 3},
              4 => {label: t('4 Miles'), display_type: :select_box_value, name: :distance, value: 4},
              5 => {label: t('5 Miles'), display_type: :select_box_value, name: :distance, value: 5},
              10 => {label: t('10 Miles'), display_type: :select_box_value, name: :distance, value: 10},
              15 => {label: t('15 Miles'), display_type: :select_box_value, name: :distance, value: 15},
              20 => {label: t('20 Miles'), display_type: :select_box_value, name: :distance, value: 20},
              25 => {label: t('25 Miles'), display_type: :select_box_value, name: :distance, value: 25},
              30 => {label: t('30 Miles'), display_type: :select_box_value, name: :distance, value: 30},
              60 => {label: t('60 Miles'), display_type: :select_box_value, name: :distance, value: 60}
            }
          }
        }
      },
      st: {
        label: t('School Type'),
        display_type: :title,
        name: :st,
        filters: {
          public: {label: t('Public district schools'), display_type: :basic_checkbox, name: :st, value: :public},
          charter: {label: t('Public charter schools'), display_type: :basic_checkbox, name: :st, value: :charter},
          private: {label: t('Private schools'), display_type: :basic_checkbox, name: :st, value: :private}
        }
      },
      gs_rating: {
        label: t('GreatSchools Rating'),
        display_type: :title,
        name: :gs_rating,
        filters: {
          above_average: {label: t('Above average (8-10)'), display_type: :basic_checkbox, name: :gs_rating, value: :above_average},
          average: {label: t('Average (4-7)'), display_type: :basic_checkbox, name: :gs_rating, value: :average},
          below_average: {label: t('Below average (1-3)'), display_type: :basic_checkbox, name: :gs_rating, value: :below_average}
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
          filters: default_simple_filters_hash
        },
        group2: {
          display_type: :filter_column_secondary,
          filters: {
            transportation: {
              label: t('Transportation options'),
              display_type: :title,
              name: :transportation,
              filters: {
                povided_transit: {label: t('District provided transit'), display_type: :basic_checkbox, name: :transportation, value: :provided_transit},
                public_transit: {label: t('Near public transit'), display_type: :basic_checkbox, name: :transportation, value: :public_transit}
              }
            },
            extendedHours: {
              label: t('Extended hours'),
              display_type: :title,
              name: :extendedHours,
              filters: {
                before: {label: t('Before school program'), display_type: :basic_checkbox, name: :beforeAfterCare, value: :before},
                after: {label: t('After school program'), display_type: :basic_checkbox, name: :beforeAfterCare, value: :after}
              }
            },
            dress_code: {
              label: t('Dress code'),
              display_type: :title,
              name: :dress_code,
              filters: {
                dress_code: {label: t('Dress code'), display_type: :basic_checkbox, name: :dress_code, value: :dress_code},
                uniform: {label: t('Uniform'), display_type: :basic_checkbox, name: :dress_code, value: :uniform},
                no_dress_code: {label: t('No dress code'), display_type: :basic_checkbox, name: :dress_code, value: :no_dress_code}
              }
            },
            class_offerings: {
              label: t('Class Offering'),
              display_type: :title,
              name: :class_offerings,
              filters: {
                ap: {label: t('AP courses'), display_type: :basic_checkbox, name: :class_offerings, value: :ap},
                music: {label: t('Music'), display_type: :basic_checkbox, name: :class_offerings, value: :music},
                performance_arts: {label: t('Performance arts'), display_type: :basic_checkbox, name: :class_offerings, value: :performance_arts},
                visual_media_arts: {label: t('Visual/Media arts'), display_type: :basic_checkbox, name: :class_offerings, value: :visual_media_arts},
                world_languages: {
                  label: t('World languages'),
                  name: :world_languages,
                  display_type: :collapsible_box,
                  filters: {
                    french: {label: t('French'), unique_label: t('French (class)'), display_type: :basic_checkbox, name: :class_offerings, value: :french},
                    german: {label: t('German'), unique_label: t('German (class)'), display_type: :basic_checkbox, name: :class_offerings, value: :german},
                    spanish: {label: t('Spanish'), unique_label: t('Spanish (class)'), display_type: :basic_checkbox, name: :class_offerings, value: :spanish},
                    mandarin: {label: t('Mandarin'), unique_label: t('Mandarin (class)'), display_type: :basic_checkbox, name: :class_offerings, value: :mandarin}
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
            girls_sports: {
              label: t('Girls Sports'),
              display_type: :title,
              name: :girls_sports,
              filters: {
                sports_icons: {
                  display_type: :sports_button_group,
                  name: :girls_sports,
                  filters: {
                    soccer: {label: t('Soccer'), icon: 'soccer', unique_label: t('Soccer (girls)'), display_type: :sports_button, name: :girls_sports, value: :soccer},
                    track: {label: t('Track'), icon: 'track', unique_label: t('Track (girls)'), display_type: :sports_button, name: :girls_sports, value: :track},
                    basketball: {label: t('Basketball'), icon: 'basketball', unique_label: t('Basketball (girls)'), display_type: :sports_button, name: :girls_sports, value: :basketball},
                    volleyball: {label: t('Volleyball'), icon: 'volleyball', unique_label: t('Volleyball (girls)'), display_type: :sports_button, name: :girls_sports, value: :volleyball},
                    cheerleading: {label: t('Cheerleading'), icon: 'cheerleading', unique_label: t('Cheerleading (girls)'), display_type: :sports_button, name: :girls_sports, value: :cheerleading}
                  }
                }
              }
            },
            boys_sports: {
              label: t('Boys Sports'),
              display_type: :title,
              name: :boys_sports,
              filters: {
                sports_icons: {
                  display_type: :sports_button_group,
                  name: :boys_sports,
                  filters: {
                    soccer: {label: t('Soccer'), icon: 'soccer', unique_label: t('Soccer (boys)'), display_type: :sports_button, name: :boys_sports, value: :soccer},
                    track: {label: t('Track'), icon: 'track', unique_label: t('Track (boys)'), display_type: :sports_button, name: :boys_sports, value: :track},
                    basketball: {label: t('Basketball'), icon: 'basketball', unique_label: t('Basketball (boys)'), display_type: :sports_button, name: :boys_sports, value: :basketball},
                    football: {label: t('Football'), icon: 'football', unique_label: t('Football (boys)'), display_type: :sports_button, name: :boys_sports, value: :football},
                    baseball: {label: t('Baseball'), icon: 'baseball', unique_label: t('Baseball (boys)'), display_type: :sports_button, name: :boys_sports, value: :baseball}
                  }
                }
              }
            },
            school_focus: {
              label: t('School Focus'),
              display_type: :title,
              name: :school_focus,
              filters: {
                arts: {label: t('Arts focus'), display_type: :basic_checkbox, name: :school_focus, value: :arts},
                career_tech: {label: t('Career & technology'), display_type: :basic_checkbox, name: :school_focus, value: :career_tech},
                college_focus: {label: t('College focus'), display_type: :basic_checkbox, name: :school_focus, value: :college_focus},
                is: {label: t('Independent study'), display_type: :basic_checkbox, name: :school_focus, value: :is},
                ib: {label: t('International Baccalaureate'), display_type: :basic_checkbox, name: :school_focus, value: :ib},
                montessori: {label: t('Montessori'), display_type: :basic_checkbox, name: :school_focus, value: :montessori},
                online: {label: t('Online learning'), display_type: :basic_checkbox, name: :school_focus, value: :online},
                project: {label: t('Project-based learning'), display_type: :basic_checkbox, name: :school_focus, value: :project},
                science_tech: {label: t('Science/Technology (STEM)'), display_type: :basic_checkbox, name: :school_focus, value: :science_tech},
                waldorf: {label: t('Waldorf'), display_type: :basic_checkbox, name: :school_focus, value: :waldorf},
                language_immersion: {
                  label: t('World language immersion'),
                  name: :world_language_immersion,
                  display_type: :collapsible_box,
                  filters: {
                    french: {label: t('French'), unique_label: t('French (immersion)'), display_type: :basic_checkbox, name: :school_focus, value: :french},
                    german: {label: t('German'), unique_label: t('German (immersion)'), display_type: :basic_checkbox, name: :school_focus, value: :german},
                    spanish: {label: t('Spanish'), unique_label: t('Spanish (immersion)'), display_type: :basic_checkbox, name: :school_focus, value: :spanish},
                    mandarin: {label: t('Mandarin'), unique_label: t('Mandarin (immersion)'), display_type: :basic_checkbox, name: :school_focus, value: :mandarin}
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  def t(key)
    I18n.t(key, scope: 'models.search.filter_builder')
  end
end
