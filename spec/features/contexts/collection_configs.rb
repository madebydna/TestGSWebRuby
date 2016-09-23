def bay_area_collection_config
  {
    promo: bay_area_promo,
    scorecard_fields: bay_area_scorecard_fields,
    scorecard_params: bay_area_scorecard_params,
    scorecard_subgroups_list: bay_area_scorecard_subgroups_list,
  }
end

def bay_area_promo
  {
    name: :innovate_public_schools,
    type: :send_to_partner,
    profile_modules: [:group_comparison],
  }
end

# For performance reasons, only test a representative sample of data types
def bay_area_scorecard_fields
  [
    { data_type: :school_info, partial: :school_info },
    # { data_type: :caaspp_math, partial: :percent_value, year: 2015 },
    # { data_type: :caaspp_english, partial: :percent_value, year: 2015 },
    # { data_type: :graduation_rate, partial: :percent_value, year: 2014 },
    { data_type: :a_through_g, partial: :percent_value, year: 2014 },
  ]
end

def bay_area_scorecard_params
  {
    gradeLevel: :h,
    schoolType: [:public, :charter],
    sortBy: :a_through_g,
    sortBreakdown: :hispanic,
    sortAscOrDesc: :desc,
    offset: 0,
  }
end

# For performance reasons, only test a representative sample of subgroups
def bay_area_scorecard_subgroups_list
  [
    :all_students,
    # :african_american,
    # :asian,
    # :filipino,
    :hispanic,
    # :multiracial,
    # :native_american_or_native_alaskan,
    # :pacific_islander,
    # :white,
    # :economically_disadvantaged,
    # :limited_english_proficient,
  ]
end
