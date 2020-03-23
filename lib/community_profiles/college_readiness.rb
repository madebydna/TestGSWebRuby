module CommunityProfiles
  class CollegeReadiness
    attr_reader :cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns
    include CollegeReadinessConfig

    TABS = {'college_readiness' => CHAR_CACHE_ACCESSORS, 'college_success' => CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS}

    def initialize(cache_data_reader:)
      @cache_data_reader = cache_data_reader
    end

    def share_content
      # Per conversation with EP, no need to include Share button on community modules (for the foreseeable future)
      # share_tooltip_modal('College_readiness', @cache_data_reader.school)
      nil
    end

    def qualaroo_module_link
      qualaroo_iframe(:college_readiness, @cache_data_reader.school.state, @cache_data_reader.school.id.to_s)
    end

    def faq
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.college_readiness.faq'),
                        content: I18n.t(:content_html, scope: 'lib.college_readiness.faq'),
                        element_type: 'faq')
    end

    def rating
      ((1..10).to_a & [@cache_data_reader.college_readiness_rating]).first
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
      # Average ACT score, ACT participation, ACT percent college ready
      act_content = enforce_latest_year_school_value_for_data_types!(hash, ACT_SCORE, ACT_PARTICIPATION, ACT_PERCENT_COLLEGE_READY)
      # Average SAT score, SAT percent participation, SAT percent college ready
      sat_content = enforce_latest_year_school_value_for_data_types!(hash, SAT_SCORE, SAT_PARTICIPATION, SAT_PERCENT_COLLEGE_READY)

      # JT-8787: Displayed ACT & SAT data must be within 2 years of one another, otherwise hide the older data type
      if act_content && sat_content && ((act_content - sat_content).abs > 2)
        if act_content > sat_content
          remove_crdc_breakdown!(hash, SAT_SCORE, SAT_PARTICIPATION, SAT_PERCENT_COLLEGE_READY)
        else
          remove_crdc_breakdown!(hash, ACT_SCORE, ACT_PARTICIPATION, ACT_PERCENT_COLLEGE_READY)
        end
      end
      if act_content || sat_content
        remove_crdc_breakdown!(hash, ACT_SAT_PARTICIPATION, ACT_SAT_PARTICIPATION_9_12)
      else
        enforce_latest_year_gsdata!(hash, ACT_SAT_PARTICIPATION, ACT_SAT_PARTICIPATION_9_12)
        part912 = hash.slice(ACT_SAT_PARTICIPATION_9_12).values.flatten.select(&:all_students?).flatten
        remove_crdc_breakdown!(hash, ACT_SAT_PARTICIPATION) if part912.present?
      end
    end

    def enforce_latest_year_gsdata!(hash, *data_types)
      data_type_hashes = hash.slice(*data_types).values.flatten.select(&:all_students?).flatten.extend(GsdataCaching::GsDataValue::CollectionMethods)
      max_year = data_type_hashes.year_of_most_recent
      data_type_hashes.each do |v|
        if v.year < max_year
          v.school_value = nil
        end
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

    # TODO Create method to handle ACT_SAT_PARTICIPATION
    # Assuming we have >= 1 year(s)' worth of school_values for a given data type,
    # this will return the most recent year (i.e., "max year") for which we have data
    # and set all previous years' school_values to nil
    def enforce_latest_year_school_value_for_data_types!(hash, *data_types)
      return_value = nil
      data_type_hashes = hash.slice(*data_types).values.flatten.select do |tds|
        tds.all_subjects? && tds.all_students?
      end.flatten
      max_year = data_type_hashes.map { |dts| dts.year }.max
      data_type_hashes.each do |h|
        if school_value_present?(h["school_value_#{max_year}"])
          return_value = max_year
        else
          h.school_value = nil if h.respond_to?(:school_value)
        end
      end
      return_value
    end

    def qualaroo_params
      state = @cache_data_reader.school.state.upcase
      school = @cache_data_reader.school.id.to_s
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

    def sources
      content = '<div class="sourcing">'

      data_array = components.map(&:data_type_hashes)
                             .reduce(:+)
                             .sort_by {|h| h.year&.to_i}
                             .reverse
                             .uniq {|h| h.data_type}
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
      @cache_data_reader.college_readiness_rating_year.to_s
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
        tabs.map {|tab| CommunityProfiles::CollegeReadinessComponent.new(tab, @cache_data_reader) }
      )
    end

    def props
      @_props ||= components.map {|component| get_props(component)}.reject(&:empty?)
    end

    def ethnicities_to_percentages
      SchoolProfiles::EthnicityPercentages.new(
        cache_data_reader: @cache_data_reader
      ).ethnicities_to_percentages
    end

    # TODO: refactor / test
    def value_to_s(value, precision=0)
      return nil if value.nil?
      return value.scan(/\d+/) if value.instance_of?(String) && value.present?
      num = value.to_f.round(precision)
      if precision.zero? && num < 1
        '<1'
      else
        num.to_s
      end
    end

    private

    def with_district_values
      ->(h) { h.has_key?('district_value') && h['district_value'].present? }
    end
  end
end
