module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader
    include Qualaroo

    FOUR_YEAR_GRADE_RATE = '4-year high school graduation rate'
    UC_CSU_ENTRANCE = 'Percent of students who meet UC/CSU entrance requirements'
    SAT_SCORE = 'Average SAT score'
    SAT_PARTICIPATION = 'SAT percent participation'
    ACT_SCORE = 'Average ACT score'
    ACT_PARTICIPATION = 'ACT participation'
    AP_ENROLLED = 'Percentage AP enrolled grades 9-12'
    AP_EXAMS_PASSED = 'Percentage of students passing 1 or more AP exams grades 9-12'
    ACT_SAT_PARTICIPATION = 'Percentage SAT/ACT participation grades 11-12'
    NEW_SAT_STATES = %w(ca mi nj)
    NEW_SAT_YEAR = 2016
    NEW_SAT_RANGE = (400..1600)
    OLD_SAT_RANGE = (600..2400)

    # Order matters - items display in configured order
    CHAR_CACHE_ACCESSORS = [
      {
        :cache => :characteristics,
        :data_key => FOUR_YEAR_GRADE_RATE,
        :visualization => :person_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => UC_CSU_ENTRANCE,
        :visualization => :single_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => SAT_SCORE,
        :visualization => :single_bar_viz,
        :formatting => [:round],
        :range => (600..2400)
      },
      {
        :cache => :characteristics,
        :data_key => SAT_PARTICIPATION,
        :visualization => :person_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => ACT_SCORE,
        :visualization => :single_bar_viz,
        :formatting => [:round],
        :range => (1..36)
      },
      {
        :cache => :characteristics,
        :data_key => ACT_PARTICIPATION,
        :visualization => :person_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => AP_ENROLLED,
        :visualization => :person_bar_viz,
        :formatting => [:to_f, :round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => AP_EXAMS_PASSED,
        :visualization => :single_bar_viz,
        :formatting => [:to_f, :round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => ACT_SAT_PARTICIPATION,
        :visualization => :person_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      }
    ].freeze

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def qualaroo_module_link
      qualaroo_iframe(:college_readiness, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def faq
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.college_readiness.faq'),
                        content: I18n.t(:content_html, scope: 'lib.college_readiness.faq'))
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

    def narration
      return nil unless rating.present? && (1..10).cover?(rating.to_i)
      key = '_' + ((rating / 2) + (rating % 2)).to_s + '_html'
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

    def included_data_types(cache = nil)
      config_for_cache = CHAR_CACHE_ACCESSORS.select { |c| cache.nil? || c[:cache] == cache }
      config_for_cache.map { |mapping| mapping[:data_key] }
    end

    def data_type_formatting_map
      @_data_type_to_value_type_map ||= (
        CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:formatting]
        end
      )
    end

    def data_type_visualization_map
      @_data_type_visualization_map ||= (
        CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:visualization]
        end
      )
    end

    def data_type_range_map
      @_data_type_range_map ||= (
      CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:range] || (0..100)
      end
      )
    end

    def data_type_hashes
      hashes = school_cache_data_reader.characteristics_data(*included_data_types(:characteristics))
      hashes.merge!(school_cache_data_reader.gsdata_data(*included_data_types(:gsdata)))
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
        values = values.select { |h| !h.has_key?('subject') || h['subject'] == 'All subjects'}
        GSLogger.error(:misc, nil,
                       message:"Failed to find unique data point for data type #{key} in the characteristics/gsdata cache",
                       vars: {school: {state: @school_cache_data_reader.school.state,
                                       id: @school_cache_data_reader.school.id}
                       }) if values.size > 1
        hash = values.first
        hash['data_type'] = key if hash
        hash
      end
      hashes.compact.select(&with_school_values).sort_by { |o| included_data_types.index( o['data_type']) }
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

    def data_values
      Array.wrap(data_type_hashes).map do |hash|
        data_type = hash['data_type']
        formatting = data_type_formatting_map[data_type]
        visualization = data_type_visualization_map[data_type]
        range = data_type_range_map[data_type]
        state = @school_cache_data_reader.school.state
        RatingScoreItem.new.tap do |item|
          item.label = data_label(data_type)
          item.year = hash['year'] || (hash['source_date_valid'] || '')[0..3]
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
      end
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
      description = rating_description
      description = data_label(description) if description
      methodology = rating_methodology
      methodology = data_label(methodology) if methodology
      content = '<div class="sourcing">'
      content << '<h1>' + data_label('title') + '</h1>'
      content << '<div>'
      content << '<h4>' + data_label('GreatSchools Rating') + '</h4>'
      if description || methodology
        content << '<p>'
        content << description if description
        content << ' ' if description && methodology
        content << methodology if methodology
        content << '</p>'
      end
      content << '<p><span class="emphasis">' + data_label('source') + '</span>: GreatSchools, ' + rating_year + '</p>'
      content << '</div>'
      content << data_type_hashes.reduce('') do |string, hash|
        string << sources_for_view(hash)
      end
      content << '</div>'
    end

    def sources_for_view(hash)
      year = hash['year'] || (hash['source_date_valid'] || '')[0..3]
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
      data_values.present?
    end

    private

    def with_school_values
      ->(h) { h.has_key?('school_value') && h['school_value'].present? }
    end
  end
end
