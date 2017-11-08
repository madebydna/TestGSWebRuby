module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

    # Constants for college readiness pane
    FOUR_YEAR_GRADE_RATE = '4-year high school graduation rate'
    UC_CSU_ENTRANCE = 'Percent of students who meet UC/CSU entrance requirements'
    SAT_SCORE = 'Average SAT score'
    SAT_PARTICIPATION = 'SAT percent participation'
    ACT_SCORE = 'Average ACT score'
    ACT_PARTICIPATION = 'ACT participation'
    AP_ENROLLED = 'Percentage AP enrolled grades 9-12'
    AP_EXAMS_PASSED = 'Percentage of students passing 1 or more AP exams grades 9-12'
    ACT_SAT_PARTICIPATION = 'Percentage SAT/ACT participation grades 11-12'
    NEW_SAT_STATES = %w(ca ct mi nj co)
    NEW_SAT_YEAR = 2016
    NEW_SAT_RANGE = (400..1600)
    OLD_SAT_RANGE = (600..2400)
    # Constants for college success pane
    SENIORS_FOUR_YEAR = 'Graduating seniors pursuing 4 year college/university'
    SENIORS_TWO_YEAR = 'Graduating seniors pursuing 2 year college/university'
    SENIORS_ENROLLED_OTHER = 'Graduating seniors pursuing other college'
    SENIORS_ENROLLED = 'Percent Enrolled in College Immediately Following High School'
    GRADUATES_REMEDIATION = 'Percent Needing Remediation for College'
    GRADUATES_PERSISTENCE = 'Percent Enrolled in College and Returned for a Second Year'
    GRADUATES_COLLEGE_VOCATIONAL = 'Percent enrolled in any institution of higher learning in the last 0-16 months'
    GRADUATES_TWO_YEAR = 'Percent enrolled in a 2-year institution of higher learning in the last 0-16 months'
    GRADUATES_FOUR_YEAR = 'Percent enrolled in a 4-year institution of higher learning in the last 0-16 months'
    GRADUATES_OUT_OF_STATE = 'Percent of students who will attend out-of-state colleges'
    GRADUATES_IN_STATE = 'Percent of students who will attend in-state colleges'
    # States for which college success data has been loaded
    CS_STATES_WHITELIST = ['AR', 'CO', 'DE', 'FL', 'GA', 'IL', 'IN', 'MO', 'NJ', 'NY', 'OH', 'OK', 'TX', 'WI', 'PA']
    # Order matters - items display in configured order

    # characteristics cache accessors for college success pane
    CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS = [
      {
        :cache => :characteristics,
        :data_key => SENIORS_FOUR_YEAR,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => SENIORS_TWO_YEAR,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => SENIORS_ENROLLED_OTHER,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => SENIORS_ENROLLED,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => GRADUATES_COLLEGE_VOCATIONAL,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => GRADUATES_TWO_YEAR,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => GRADUATES_FOUR_YEAR,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => GRADUATES_OUT_OF_STATE,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => GRADUATES_IN_STATE,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => GRADUATES_REMEDIATION,
        :visualization => 'person_reversed',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => GRADUATES_PERSISTENCE,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      }
    ]

    # characteristics cache accessors for college readiness pane
    CHAR_CACHE_ACCESSORS = [
      {
        :cache => :characteristics,
        :data_key => FOUR_YEAR_GRADE_RATE,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => UC_CSU_ENTRANCE,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => SAT_SCORE,
        :visualization => 'bar',
        :formatting => [:round],
        :range => (600..2400)
      },
      {
        :cache => :characteristics,
        :data_key => SAT_PARTICIPATION,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => ACT_SCORE,
        :visualization => 'bar',
        :formatting => [:round],
        :range => (1..36)
      },
      {
        :cache => :characteristics,
        :data_key => ACT_PARTICIPATION,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => AP_ENROLLED,
        :visualization => 'person',
        :formatting => [:to_f, :round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => AP_EXAMS_PASSED,
        :visualization => 'bar',
        :formatting => [:to_f, :round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => ACT_SAT_PARTICIPATION,
        :visualization => 'person',
        :formatting => [:round_unless_less_than_1, :percent]
      }
    ].freeze

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

    def

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
      config_for_cache = cache_accessors.select { |c| cache.nil? || c[:cache] == cache }
      config_for_cache.map { |mapping| mapping[:data_key] }
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
      hashes.compact.select(&with_school_values).sort_by { |o| included_data_types(cache_accessors).index( o['data_type']) }
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
        # next if cache_accessors == CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS && hash['year'].to_i < 2015
        data_type = hash['data_type']
        formatting = data_type_formatting_map(cache_accessors)[data_type]
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

    def college_readiness_group_array
      values = data_values(CHAR_CACHE_ACCESSORS).map do |score_item|
        {label: score_item.score.to_f.round.to_s,
         score: score_item.score.value.to_i,
         breakdown: score_item.label,
         state_average: score_item.state_average.value.to_i,
         state_average_label: score_item.state_average.value.to_f.round.to_s,
         display_type: score_item.visualization,
         lower_range: score_item.range.first,
         upper_range: score_item.range.last,
         tooltip_html: score_item.info_text
         }
      end
      [{narration: narration(:college_readiness), title: 'College readiness', values: values}]
    end

    def college_success_group_array
      @_college_success_group_array ||= data_values(CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS).map do |score_item|
        {label: score_item.score.to_f.round.to_s,
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
      return nil if @_college_success_group_array.empty?
      [{narration: narration(:college_success), title: 'College success', values: @_college_success_group_array}]
    end

    def feedback_data
      @_feedback_data ||= {
        'feedback_cta' => I18n.t('feedback_cta', scope:'school_profiles.college_readiness'),
        'feedback_link' => 'https://s.qualaroo.com/45194/cb0e676f-324a-4a74-bc02-72ddf1a2ddd6',
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
      content << data_type_hashes(CHAR_CACHE_ACCESSORS + CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS).reduce('') do |string, hash|
        string << sources_for_view(hash)
      end
      content << '</div>'
    end

    def college_readiness_props
      return nil unless CS_STATES_WHITELIST.include?(@school_cache_data_reader.school.state.upcase)
      @_college_readiness_props ||= {
        title: I18n.t('title', scope:'school_profiles.college_readiness'),
        anchor: 'College_readiness',
        data: college_readiness_group_array
      }
    end

    def college_success_props
      return @_college_success_props if defined? @_college_success_props
      @_college_success_props ||= (
        if college_success_group_array.nil?
          nil
        else
          {
            title: I18n.t('title', scope:'school_profiles.college_success'),
            anchor: 'College_success',
            data: college_success_group_array
          }
        end
      )
    end

    def props
      @_props ||= [college_readiness_props, college_success_props].compact
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
