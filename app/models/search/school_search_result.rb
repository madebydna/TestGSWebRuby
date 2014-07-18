class SchoolSearchResult
  include ActionView::Helpers::AssetTagHelper

  attr_accessor :fit_score, :max_fit_score, :fit_score_map, :on_page, :overall_gs_rating

  SOFT_FILTER_FIELD_MAP = Hash.new({}).merge!({
    beforeAfterCare: {
      before: :before_after_care,
      after: :before_after_care
    },
    transporation: {
      public_transit: :Transportation,
      provided_transit: :Transportation
    },
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
    },
    class_offerings: {
      ap: :instructional_model,
      performance_arts: :arts_performing_written,
      visual_media_arts: [:arts_visual, :arts_media],
      music: :arts_music,
      french: :foreign_language,
      german: :foreign_language,
      spanish: :foreign_language,
      mandarin: :foreign_language
    }
  })
  # Rollup values
  SOFT_FILTER_VALUE_MAP = Hash.new({}).merge!({
    transportation: {
      public_transit: [/^accessible_via_public_transportation$/, /^passes$/],
      provided_transit: [/^busses$/, /^shared_bus$/]
    },
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
      online: [/^virtual$/, /^hybrid$/] #ToDo Check OSP Values
    },
    class_offerings: {
      ap: /^AP_courses$/,
      performance_arts: /\w*/,
      visual_media_arts: /\w*/,
      music: /\w*/,
      french: /^french$/,
      german: /^german$/,
      spanish: /^spanish$/,
      mandarin: /^mandarin$/
    }
  })

  def initialize(hash)
    @fit_score = 0
    @max_fit_score = 0
    @fit_score_map = {}
    @attributes = hash
    @attributes.each do |k,v|
      define_singleton_method k do v end
    end
  end

  def preschool?
    (respond_to?('level_code') && level_code == 'p')
  end

  # Increments fit score for each matching key/value pair from params
  def calculate_fit_score(params)
    @fit_score = 0
    @fit_score_map = {}
    @max_fit_score = 0
    params.each do |key, value|
      @fit_score_map[key] ||= {}
      [*value].each do |v|
        @max_fit_score += 1
        is_match = matches_soft_filter?(key, v)
        @fit_score += 1 if is_match
        @fit_score_map[key][v] = is_match
      end
    end
  end

  protected

  def matches_soft_filter?(param, value)
    # Default return value of SOFT_FILTER_FIELD_MAP and SOFT_FILTER_VALUE_MAP set to empty hash if no key found.
    filters = SOFT_FILTER_FIELD_MAP[param.to_sym][value.to_sym] || param.to_sym
    filter_value_map = SOFT_FILTER_VALUE_MAP[param.to_sym][value.to_sym] || /^#{value}$/
    [*filters].each do |filter|
      if filter && respond_to?(filter)
        search_result_value = send(filter)
        [*filter_value_map].each do |val|
          [*search_result_value].each { |v| return true if v.match(val) }
        end
      end
    end
    false #Returns false even if no soft filter is not supported. Intended?
  end
end
