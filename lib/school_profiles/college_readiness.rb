module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns
    include MetricsCaching::CollegeReadinessConfig

    TABS = {'college_readiness' => CHAR_CACHE_ACCESSORS, 'college_success' => CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS}

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def share_content
      share_tooltip_modal('College_readiness', @school_cache_data_reader.school)
    end

    def qualaroo_module_link
      qualaroo_iframe(:college_readiness, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def faq
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'school_profiles.college_readiness.faq'),
                        content: I18n.t(:content_html, scope: 'school_profiles.college_readiness.faq'),
                        element_type: 'faq')
    end

    def rating
      ((1..10).to_a & [@school_cache_data_reader.college_readiness_rating]).first
    end

    def show_historical_ratings?
      false
    end

    def info_text
      I18n.t('school_profiles.college_readiness.info_text')
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'school_profiles.college_readiness', default: I18n.db_t(key, default: key))
    end

    def data_label_info_text(key)
      I18n.t(key.to_sym, scope: 'school_profiles.college_readiness.data_point_info_texts')
    end

    def qualaroo_params
      state = @school_cache_data_reader.school.state.upcase
      school = @school_cache_data_reader.school.id.to_s
      '?' + 'school=' + school + '&' + 'state=' + state
    end

    def feedback_data
      @_feedback_data ||= {
        'feedback_cta' => I18n.t('feedback_cta', scope:'school_profiles.college_readiness'),
        'feedback_link' => 'https://s.qualaroo.com/45194/cb0e676f-324a-4a74-bc02-72ddf1a2ddd6' + qualaroo_params,
        'button_text' =>  I18n.t('Answer', scope:'school_profiles.college_readiness')
      }
    end

    def sat_score_range(state, year)
      new_sat?(state, year) ? NEW_SAT_RANGE : OLD_SAT_RANGE
    end

    def sat_score_info_text_key(state, year)
      new_sat?(state, year) ? "#{SAT_SCORE}_new" : SAT_SCORE
    end

    def sat_percent_college_ready_text_key(grade)
      grade == 'All' ? SAT_PERCENT_COLLEGE_READY : MetricsCaching::CollegeReadinessConfig.const_get("SAT_PERCENT_COLLEGE_READY_#{grade}")
    end

    def new_sat?(state, year)
      NEW_SAT_STATES.include?(state.to_s.downcase) && year.to_i >= NEW_SAT_YEAR
    end

    def rating_description
      @school_cache_data_reader.college_readiness_rating_hash.try(:description)
    end

    def rating_methodology
      @school_cache_data_reader.college_readiness_rating_hash.try(:methodology)
    end

    def sources
      content = '<div class="sourcing">'
      content << '<h1>' + data_label('sources_title') + '</h1>'
      if rating.present? && rating != 'NR'
        content << rating_source(year: rating_year, label: data_label('GreatSchools Rating'),
                                 description: rating_description, methodology: rating_methodology,
                                 more_anchor: 'collegereadinessrating')
      end

      data_array = components.map(&:data_type_hashes).reduce(:+)
      content << data_array.reduce('') do |string, hash|
        string << sources_text(hash)
      end
      content << '</div>'
    end

    def sources_text(hash)
      year = hash['year'] || ((hash['source_date_valid'] || '')[0..3]).presence || hash['source_year']
      source = hash['source'] || hash['source_name']
      str = '<div>'
      str << '<h4>' + data_label(hash['data_type']) + '</h4>'
      str << "<p>#{data_label_info_text(hash['data_type'])}</p>"
      if year && source
        str << '<p><span class="emphasis">' + data_label('source')+ '</span>: ' + I18n.db_t(source, default: source) + ', ' + year.to_s + '</p>'
      else
        GSLogger.error( :misc, nil, message: "Missing source or missing year", vars: hash)
      end
      str << '</div>'
      str
    end

    def rating_year
      @school_cache_data_reader.college_readiness_rating_year.to_s
    end

    def visible?
      props.present?
    end

    def tabs
      ['college_readiness']
    end

    def get_props(component)
      return {} if component.empty_data?
      {
        title: I18n.t('title', scope: component.scope),
        anchor: component.tab.capitalize,
        data: component.college_data_array
      }
    end

    def components
      @_components ||= (
      tabs.map {|tab| SchoolProfiles::CollegeReadinessComponent.new(tab, @school_cache_data_reader) }
      )
    end

    def has_college_success?
      props.any? {|component| component[:anchor] == 'College_success' }
    end

    def props
      @_props ||= components.map {|component| get_props(component)}.reject(&:empty?)
    end

    private

    def with_school_values
      ->(h) { h.has_key?('school_value') && h['school_value'].present? }
    end
  end
end
