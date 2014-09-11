module FitScoreConcerns
  extend ActiveSupport::Concern

  included do
    attr_accessor :fit_score, :fit_score_breakdown, :max_fit_score
  end

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
    }.stringify_keys!
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
      performance_arts: /\w*/,
      visual_media_arts: /\w*/,
      music: /\w*/,
      french: /^french$/,
      german: /^german$/,
      spanish: /^spanish$/,
      mandarin: /^mandarin$/
    }.stringify_keys!
  }.stringify_keys!)

  # Increments fit score for each matching key/value pair from params
  def calculate_fit_score!(params)
    @fit_score = 0
    @fit_score_breakdown = []
    @max_fit_score = 0
    params.each do |key, value|
      [*value].each do |v|
        @max_fit_score += 1
        is_match = matches_soft_filter?(key, v)
        @fit_score += 1 if is_match
        @fit_score_breakdown << {category: key, filter: v, match: is_match}
      end
    end
    @fit_score_breakdown.sort! do |a, b|
      if a[:match] == b[:match]
        a[:filter] <=> b[:filter]
      elsif a[:match]
        -1
      else
        1
      end
    end
  end

  protected

  def matches_soft_filter?(param, value)
    # Default return value of SOFT_FILTER_FIELD_MAP and SOFT_FILTER_VALUE_MAP set to empty hash if no key found.
    filters = SOFT_FILTER_FIELD_MAP[param][value] || param
    filter_value_map = SOFT_FILTER_VALUE_MAP[param][value] || /^#{value}$/
    [*filters].each do |filter|
      filter_values = []
      if filter && respond_to?(filter) && !send(filter).nil?
        filter_values = [*send(filter)]
      elsif filter && respond_to?(:programs) && !programs.nil? && programs.key?(filter.to_s)
        filter_values = programs[filter.to_s].keys
      end
      [*filter_value_map].each { |val| filter_values.each { |v| return true if v.match(val) } }
    end
    false #Returns false even if no soft filter is not supported. Intended?
  end

end