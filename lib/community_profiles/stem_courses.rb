module CommunityProfiles
  class StemCourses
    include Qualaroo
    include SharingTooltipModal

    attr_reader :cache_data_reader

    def initialize(cache_data_reader:)
      @cache_data_reader = cache_data_reader
    end

    def share_content
      # Per conversation with EP, no need to include Share button on community modules (for the foreseeable future)
      # share_tooltip_modal('Advanced_courses', @cache_data_reader.district)
      nil
    end

    def qualaroo_module_link
      qualaroo_iframe(:advanced_stem, @cache_data_reader.district.state, @cache_data_reader.district.id.to_s)
    end

    def data_types_and_visualizations
      {
          'Percentage algebra 1 enrolled grades 7-8' => :PersonBar,
          'Percentage passing algebra 1 grades 7-8' => :SingleBar,
          'Percent of students enrolled in Algebra 1' => :PersonBar,
          'Percent of students passing Algebra 1' => :SingleBar,
          'Percentage AP math enrolled grades 9-12' => :PersonBar,
          'Percentage AP science enrolled grades 9-12' => :PersonBar,
          'Percentage AP other courses enrolled grades 9-12' => :PersonBar
      }
    end

    # JT-8999: Display 2016 8th grade algebra data types (#321 & #322) if either are available.
    # Otherwise, display 2014 7th/8th grade algebra data types (#23 & #27).
    def prioritize_freshest_algebra_data!(hash)
      if hash["Percent of students enrolled in Algebra 1"] || hash["Percent of students passing Algebra 1"]
        hash.delete("Percentage algebra 1 enrolled grades 7-8")
        hash.delete("Percentage passing algebra 1 grades 7-8")
      end
      hash
    end

    def data_types
      data_types_and_visualizations.keys
    end

    def stem_data
      @_stem_data ||= begin
        all_data = @cache_data_reader.decorated_gsdata_datas(*data_types)

        prioritize_freshest_algebra_data!(all_data)
      end
    end

    def stem_courses_hashes
      stem_data.each_with_object([]) do |(data_type, bd_hashes), accum|
        bd_hashes.for_all_students.having_district_value.having_most_recent_date.each do |data_value|
          val = data_value.district_value.to_f.round
          accum << {
              breakdown: I18n.t(data_type, scope: 'lib.stem_courses', default:{})[:label],
              score: val,
              label: val < 1 ? '<1' : "#{val}",
              state_average: data_value.state_value.to_f.round,
              visualization: data_types_and_visualizations[data_type],
              tooltip_html: I18n.t(data_type, scope: 'lib.stem_courses', default:{})[:tooltip_html]
          }
        end
      end
    end

    # look into this
    def stem_courses_sources
      stem_data.each_with_object([]) do |(data_type, bd_hashes), accum|
        bd_hashes.for_all_students.having_district_value.having_most_recent_date.each do |data_value|
          accum << {
            data_type: I18n.t(data_type, scope: 'lib.stem_courses', default:{})[:label],
            source_year: data_value.source_year,
            source_name: I18n.db_t(data_value.source_name)
          }
        end
      end.uniq
    end

    def stem_courses_props
      {
        courses: stem_courses_hashes,
        sources: stem_courses_sources,
        share_content: share_content,
        title: I18n.t('.title', scope: 'lib.stem_courses'),
        titleTooltipText: I18n.t('.title_tooltip_text_html', scope: 'lib.stem_courses'),
        subtitle: I18n.t('.subtitle_html', scope: 'lib.stem_courses'),
        parentTip: I18n.t('.parent_tip_html', scope: 'lib.stem_courses'),
        faqCta: I18n.t('.faq_cta', scope: 'lib.stem_courses'),
        faqContent: I18n.t('.faq_content_html', scope: 'lib.stem_courses'),
        qualaroo_module_link: qualaroo_module_link
      }
    end

    def visible?
      stem_courses_hashes.present?
    end
  end
end