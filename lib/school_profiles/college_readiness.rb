module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns
    include CollegeReadinessConfig

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
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.college_readiness.faq'),
                        content: I18n.t(:content_html, scope: 'lib.college_readiness.faq'),
                        element_type: 'faq')
    end

    def rating
      ((1..10).to_a & [@school_cache_data_reader.college_readiness_rating]).first
    end

    def show_historical_ratings?
      false
    end

    def info_text
      I18n.t('lib.college_readiness.info_text')
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.college_readiness', default: I18n.db_t(key, default: key))
    end

    def data_label_info_text(key)
      I18n.t(key.to_sym, scope: 'lib.college_readiness.data_point_info_texts')
    end

    def school_value_present?(value)
      value.present? && value.to_s != '0.0' && value.to_s != '0'
    end

    def handle_ACT_SAT_to_display!(hash)
      act_content = enforce_latest_year_school_value_for_data_types!(hash, ACT_SCORE, ACT_PARTICIPATION)
      sat_content = enforce_latest_year_school_value_for_data_types!(hash, SAT_SCORE, SAT_PARTICIPATION)
      if act_content || sat_content
        remove_crdc_breakdown!(hash, ACT_SAT_PARTICIPATION)
      end
    end

    def remove_crdc_breakdown!(hash, *data_types)
      data_type_hashes = hash.slice(*data_types).values.flatten.select do |tds|
        tds.all_students?
      end.flatten
      data_type_hashes.each do |h|
        h.school_value = nil
      end
    end

    # TODO Create method to handle ACT_SAT_PARTICIPATION  -  Instead of returning boolean
    def enforce_latest_year_school_value_for_data_types!(hash, *data_types)
      return_value = false
      data_type_hashes = hash.slice(*data_types).values.flatten.select do |tds|
        tds.all_subjects? && tds.all_students?
      end.flatten
      max_year = data_type_hashes.map { |dts| dts.year }.max
      data_type_hashes.each do |h|
        if school_value_present?(h["school_value_#{max_year}"])
          return_value = true
        else
          h.school_value = nil
        end
      end
      return_value
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
      content << '<h1>' + data_label('title') + '</h1>'
      if rating.present? && rating != 'NR'
        content << rating_source(year: rating_year, label: data_label('GreatSchools Rating'),
                                 description: rating_description, methodology: rating_methodology,
                                 more_anchor: 'collegereadinessrating')
      end

      data_array = components.map(&:data_type_hashes).reduce(:+)
      content << data_array.reduce('') do |string, hash|
        string << sources_for_view(hash)
      end
      content << '</div>'
    end

    def sources_for_view(hash)
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
      data_values(CHAR_CACHE_ACCESSORS).present? || data_values(CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS).present?
    end

    def tabs
      @_tabs ||= TABS.keys
    end

    def get_props(component)
      return {} if component.empty_data?
      hash = {
          title: I18n.t('title', scope: component.scope),
          anchor: component.tab.capitalize,
          data: component.college_data_array
      }
      hash.merge!(csa_props(component)) if component.tab == 'college_success' && component.csa_badge?
      hash
    end

    def csa_props(component)
      return nil unless component.csa_badge?
      {
        csa_badge: I18n.t(:csa_badge_html, scope: 'lib.college_readiness').html_safe
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

    def school_csa_badge?
      school_cache_data_reader.csa_badge?
    end

    private

    def with_school_values
      ->(h) { h.has_key?('school_value') && h['school_value'].present? }
    end
  end
end
