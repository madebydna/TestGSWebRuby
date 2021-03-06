module FitScoreConcerns
  extend ActiveSupport::Concern

  included do
    attr_accessor :fit_score, :fit_score_breakdown, :max_fit_score, :fit_ratio
  end

  STRONG_FIT_CUTOFF = 0.666
  OK_FIT_CUTOFF = 0.333

  # Maps URL key/value pairs to the attribute that can answer the question
  # For example, "school_focus=science_tech" is contained in the attribute instructional_model
  # while "school_focus=career_tech" is contained in the attribute academic_focus
  SOFT_FILTER_FIELD_MAP = Hash.new({}).merge!({
    beforeAfterCare: {
      before: :before_after_care,
      after: :before_after_care
    }.stringify_keys!,
    school_focus: {
      arts: :academic_focus,
      science_tech: :instructional_model,
      career_tech: :academic_focus,
      french: :immersion_language,
      german: :immersion_language,
      spanish: :immersion_language,
      mandarin: :immersion_language,
      montessori: :instructional_model,
      ib: :instructional_model,
      is: :instructional_model,
      college_focus: :instructional_model,
      waldorf: :instructional_model,
      project: :instructional_model,
      online: :instructional_model
    }.stringify_keys!,
    class_offerings: {
      ap: :instructional_model,
      performance_arts: :arts_performing_written,
      visual_media_arts: [:arts_visual, :arts_media],
      music: :arts_music,
      french: :foreign_language,
      german: :foreign_language,
      spanish: :foreign_language,
      mandarin: :foreign_language
    }.stringify_keys!,
    enrollment: {
        vouchers: :students_vouchers
    }.stringify_keys!,
    voucher_type: {
        EdChoice:  :voucher_type,
        Autism:  :voucher_type,
        Cleveland: :voucher_type,
        "Jon Peterson Special Needs" => :voucher_type
    }.stringify_keys!,
    summer_program: {
        yes: :summer_program
    }.stringify_keys!,
    spec_ed: {
      autism: :special_ed_programs,
      blindness: :special_ed_programs,
      brain_injury: :special_ed_programs,
      cognitive: :special_ed_programs,
      deaf_blindness: :special_ed_programs,
      deafness: :special_ed_programs,
      developmental_delay: :special_ed_programs,
      emotional: :special_ed_programs,
      hearing_impairments: :special_ed_programs,
      ld: :special_ed_programs,
      multiple: :special_ed_programs,
      orthopedic: :special_ed_programs,
      other: :special_ed_programs,
      speech: :special_ed_programs,
    }.stringify_keys!,
  }.stringify_keys!)

  # Rollup values
  # A regular expression defining what attribute values match particular filters
  # For example, provided_transit is true if the transportation attribute contains either "busses" or "shared_bus"
  # If a field isn't defined here, it defaults to exact match on field name. For example,
  # boys_sports=basketball is true if the boys_sports attribute contains a value "basketball"
  SOFT_FILTER_VALUE_MAP = Hash.new({}).merge!({
    transportation: {
      public_transit: [/^accessible_via_public_transportation$/, /^passes$/],
      provided_transit: [/^busses$/, /^shared_bus$/]
    }.stringify_keys!,
    school_focus: {
      arts: [/^all_arts$/, /^visual_arts$/, /^performing_arts$/, /^music$/],
      science_tech: /^STEM$/,
      career_tech: /^vocational$/,
      french: /^french$/,
      german: /^german$/,
      spanish: /^spanish$/,
      mandarin: /^mandarin$/,
      montessori: /^montessori$/,
      ib: /^ib$/,
      is: /^independent_study$/,
      college_focus: [/^AP_courses$/, /^ib$/, /^college_prep$/],
      waldorf: /^waldorf$/,
      project: /^project_based$/,
      online: [/^virtual$/, /^hybrid$/]
  }.stringify_keys!,
    class_offerings: {
      ap: /^AP_courses$/,
      performance_arts: /^(?!none)\w+/i,
      visual_media_arts: /^(?!none)\w+/i,
      music: /^(?!none)\w+/i,
      french: /^french$/,
      german: /^german$/,
      spanish: /^spanish$/,
      mandarin: /^mandarin$/
    }.stringify_keys!,
    enrollment: {
        vouchers: {type: 'private', regex: /^yes$/}
    }.stringify_keys!,
    voucher_type: {
        Cleveland:/^Cleveland$/,
        EdChoice:  /^EdChoice$/,
        Autism:  /^Autism$/,
        Jon_Peterson_Special_Needs: /^Jon Peterson Special Needs$/
  }.stringify_keys!
  }.stringify_keys!)

  def strong_fit?
    fit_ratio && fit_ratio >= STRONG_FIT_CUTOFF
  end

  def ok_fit?
    fit_ratio && fit_ratio >= OK_FIT_CUTOFF && fit_ratio < STRONG_FIT_CUTOFF
  end

  def weak_fit?
    fit_ratio && fit_ratio > 0 && fit_ratio < OK_FIT_CUTOFF
  end

  def has_fit?
    fit_score && fit_score > 0
  end

  def fit_score_icon
    if strong_fit?
      'iconx24-icons i-24-strong-fit'
    elsif ok_fit?
      'iconx24-icons i-24-ok-fit'
    elsif weak_fit?
      'iconx24-icons i-24-weak-fit'
    end
  end

  def fit_score_text
    if strong_fit?
      I18n.t('concerns.fit_score_concerns.strong_fit')
    elsif ok_fit?
      I18n.t('concerns.fit_score_concerns.okay_fit')
    elsif weak_fit?
      I18n.t('concerns.fit_score_concerns.weak_fit')
    else
      I18n.t('concerns.fit_score_concerns.no_matches')
    end
  end

  # Increments fit score for each matching key/value pair from params
  def calculate_fit_score!(params)
    @fit_score = 0
    @fit_score_breakdown = []
    @max_fit_score = 0
    @fit_ratio = 0
    params.each do |key, value|
      [*value].each do |v|
        @max_fit_score += 1
        match_status = matches_soft_filter?(key, v)
        # not_applicable counts as a match for the purposes of sorting
        @fit_score += 1 if match_status == :yes || match_status == :not_applicable
        @fit_score_breakdown << {category: key, filter: v, match_status: match_status}
      end
    end
    if @max_fit_score > 0
      @fit_ratio = @fit_score / @max_fit_score.to_f
    end
  end

  def sort_breakdown_by_match_status!
    fit_score_breakdown.sort! do |a, b|
      if a[:match_status] == b[:match_status]
        a[:filter] <=> b[:filter]
      else
        sort_order_lookup(a[:match_status]) <=> sort_order_lookup(b[:match_status])
      end
    end unless fit_score_breakdown.nil?
  end

  def update_breakdown_labels!(filter_display_map)
    fit_score_breakdown.each do |breakdown|
      breakdown[:filter] = filter_display_map[breakdown[:category].to_sym][breakdown[:filter].to_sym] unless filter_display_map[breakdown[:category].to_sym].nil?
    end unless fit_score_breakdown.nil? || filter_display_map.nil?
  end

  protected

  def sort_order_lookup(match_status)
    return 3 if match_status == :no_data
    return 2 if match_status == :no
    return 1 if match_status == :yes
    return 4 if match_status == :not_applicable
    5 # if this line is reached there was an error somewhere
  end

  def matches_soft_filter?(param, value)
    # Default return value of SOFT_FILTER_FIELD_MAP and SOFT_FILTER_VALUE_MAP set to empty hash if no key found.
    filters = SOFT_FILTER_FIELD_MAP[param][value] || param
    filter_value_matcher = get_filter_value_matcher(param, value)  # Returns a regex or array of regexes, or a symbol to short-circuit
    return :not_applicable if filter_value_matcher == :not_applicable

    all_responses_for_filter = []
    [*filters].each do |filter|
      filter_values = get_filter_values(filter)
      next if filter_values.nil? || filter_values.empty?
      [*filter_value_matcher].each { |val| filter_values.each { |v| return :yes if v.match(val) } }
      all_responses_for_filter += filter_values
    end
    all_responses_for_filter.empty? ? :no_data : :no
  end

  def get_filter_value_matcher(param, value)
    filter_value_matcher = SOFT_FILTER_VALUE_MAP[param][value] || /^#{Regexp.escape(value)}$/
    if filter_value_matcher.is_a?(Hash)
      if filter_value_matcher[:type]
        return :not_applicable if type.downcase != filter_value_matcher[:type].downcase
      end
      filter_value_matcher = filter_value_matcher[:regex]
    end
    filter_value_matcher
  end

  def get_filter_values(filter)
    filter_values = nil
    if respond_to?(:school_cache)
      if !school_cache.programs.nil? && school_cache.programs.key?(filter.to_s)
        filter_values = school_cache.programs[filter.to_s].keys
      end
    elsif respond_to?(filter)
      potential_values = try(filter)
      filter_values = [*potential_values] unless potential_values.nil?
    end
    filter_values
  end
end
