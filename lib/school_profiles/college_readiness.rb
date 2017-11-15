module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns
    include CollegeReadinessConfig

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

    def historical_ratings
      @school_cache_data_reader.historical_college_readiness_ratings
    end

    def show_historical_ratings?
      historical_ratings.present? && historical_ratings.length > 1
    end

    def narration(pane)
      if !rating.present? && !(1..10).cover?(rating.to_i) && visible?
        key = '_parent_tip_html'
      elsif !visible?
        return nil
      elsif pane == :college_success
        key = '_college_success'
      elsif pane == :college_readiness
        key = '_' + ((rating / 2) + (rating % 2)).to_s + '_html'
      end
      I18n.t(key, scope: 'lib.college_readiness.narration', default: I18n.db_t(key, default: key)).html_safe
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

    def included_data_types(cache_accessors, cache = nil)
      # Required for the sort in data_type_hashes
      remediation_subgroups = REMEDIATION_SUBGROUPS
      config_for_cache = cache_accessors.select { |c| cache.nil? || c[:cache] == cache }
      config_for_cache.map { |mapping| mapping[:data_key] } + remediation_subgroups
      end

    def data_type_formatting_map(cache_accessors)
      cache_accessors.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:formatting]
      end
    end

    def data_type_visualization_map(cache_accessors)
      cache_accessors.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:visualization]
      end
    end

    def data_type_range_map(cache_accessors)
      cache_accessors.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:range] || (0..100)
      end
    end

    def data_type_hashes(cache_accessors)
      hashes = school_cache_data_reader.characteristics_data(*included_data_types(cache_accessors, :characteristics ))
      hashes.merge!(school_cache_data_reader.gsdata_data(*included_data_types(cache_accessors,:gsdata )))
      return [] if hashes.blank?
      handle_ACT_SAT_to_display!(hashes)
      hashes = hashes.map do |key, array|
        values = array.select do |h|
          # If it has no breakdown keys, that's good (gsdata)
          (!h.has_key?('breakdowns') && !h.has_key?('breakdown')) ||
          # otherwise the breakdown better be 'All students' (characteristics)
              h['breakdown'] == 'All students'
        end
        # This is for characteristics

        unless key == GRADUATES_REMEDIATION
          values = values.select { |h| !h.has_key?('subject') || h['subject'] == 'All subjects'}
          GSLogger.error(:misc, nil,
                         message:"Failed to find unique data point for data type #{key} in the characteristics/gsdata cache",
                         vars: {school: {state: @school_cache_data_reader.school.state,
                                         id: @school_cache_data_reader.school.id}
                         }) if values.size > 1
        end
        add_data_type(key,values)
      end
      data_values = hashes.flatten.compact.select(&with_school_values)
      data_values.select! { |dv| included_data_types(cache_accessors).include?(dv['data_type']) }
      data_values.sort_by { |o| included_data_types(cache_accessors).index( o['data_type']) }
    end

    def add_data_type(key,values)
      # Special handling for Remediation data, which is organized by subject
      if key == GRADUATES_REMEDIATION
        arr = values.map do |hash|
          if hash.has_key?('subject')
            hash.merge('data_type' => 'Graduates needing ' + hash['subject'].capitalize + ' remediation in college')
          else
            hash.merge('data_type' => key)
          end
        end
        arr
      else
        hash = values.first
        hash['data_type'] = key if hash
        hash
      end
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
        tds['breakdowns'].nil?
      end.flatten
      data_type_hashes.each do |h|
        h['school_value'] = nil
      end
    end
    # TODO Create method to handle ACT_SAT_PARTICIPATION  -  Instead of returning boolean
    def enforce_latest_year_school_value_for_data_types!(hash, *data_types)
      return_value = false
      data_type_hashes = hash.slice(*data_types).values.flatten.select do |tds|
        tds['subject'] == 'All subjects' && tds['breakdown'] == 'All students'
      end.flatten
      max_year = data_type_hashes.map { |dts| dts['year'] }.max
      data_type_hashes.each do |h|
        if school_value_present?(h["school_value_#{max_year}"])
          return_value = true
        else
          h['school_value'] = nil
        end
      end
      return_value
    end

    def data_values(cache_accessors)
      Array.wrap(data_type_hashes(cache_accessors)).map do |hash|
        next if cache_accessors == CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS && hash['year'].to_i < DATA_CUTOFF_YEAR
        data_type = hash['data_type']
        formatting = data_type_formatting_map(cache_accessors)[data_type] || [:round_unless_less_than_1, :percent]
        visualization = data_type_visualization_map(cache_accessors)[data_type]
        range = data_type_range_map(cache_accessors)[data_type]
        state = @school_cache_data_reader.school.state
        RatingScoreItem.new.tap do |item|
          item.label = data_label(data_type)
          item.year = hash['year'] || ((hash['source_date_valid'] || '')[0..3]).presence || hash['source_year']
          if data_type == SAT_SCORE
            item.info_text = data_label_info_text(sat_score_info_text_key(state, item.year))
            item.range = sat_score_range(state, item.year)
          else
            item.info_text = data_label_info_text(data_type)
            item.range = range
          end
          item.score = SchoolProfiles::DataPoint.new(hash['school_value']).
            apply_formatting(*formatting)
          state_average = hash['state_average'] || hash['state_value']
          item.state_average = SchoolProfiles::DataPoint.new(state_average).
            apply_formatting(*formatting)
          item.visualization = visualization
          item.source = hash['source'] || hash['source_name']
        end
      end.compact
    end

    def college_data_array(pane)
      cache_accessors = pane == 'college_success' ? CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS : CHAR_CACHE_ACCESSORS
      data_values = data_values(cache_accessors).map do |score_item|
        {label: score_item.score.format.to_s.chomp('%'),
         score: score_item.score.value.to_i,
         breakdown: score_item.label,
         state_average: score_item.state_average.value.to_i,
         state_average_label: score_item.state_average.value.to_f.round.to_s,
         display_type: score_item.visualization,
         lower_range: (score_item.range.first if score_item.range),
         upper_range: (score_item.range.last if score_item.range),
         tooltip_html: score_item.info_text
        }
      end
      [{narration: narration(pane.to_sym), title: pane.humanize, values: data_values}]
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
      hash = @school_cache_data_reader.college_readiness_rating_hash
      hash['description'] if hash
    end

    def rating_methodology
      hash = @school_cache_data_reader.college_readiness_rating_hash
      hash['methodology'] if hash
    end

    def sources
      content = '<div class="sourcing">'
      content << '<h1>' + data_label('title') + '</h1>'
      if rating.present? && rating != 'NR'
        content << rating_source(year: rating_year, label: data_label('GreatSchools Rating'),
                                 description: rating_description, methodology: rating_methodology,
                                 more_anchor: 'collegereadinessrating')
      end
      data_array_cr = data_type_hashes(CHAR_CACHE_ACCESSORS)
      # Remove stale college success data from sources
      data_array_cs = data_type_hashes(CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS).reject {|hash| hash["year"].to_i < DATA_CUTOFF_YEAR }
      data_array = data_array_cr + data_array_cs
      content << data_array.reduce('') do |string, hash|
        string << sources_for_view(hash)
      end
      content << '</div>'
    end

    def get_props(pane)
      data_for_pane = college_data_array(pane)
      scope = 'school_profiles.' + pane
      return [] if data_for_pane[0][:values].empty?
      {
        title: I18n.t('title', scope: scope),
        anchor: pane.capitalize,
        data: data_for_pane
      }
    end

    def props
      @_props ||= [get_props('college_readiness'), get_props('college_success')].reject(&:empty?)
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

    private

    def with_school_values
      ->(h) { h.has_key?('school_value') && h['school_value'].present? }
    end
  end
end
