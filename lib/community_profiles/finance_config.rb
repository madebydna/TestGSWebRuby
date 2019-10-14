module CommunityProfiles::FinanceConfig
  TOTAL_REVENUE = 'Total Revenue'
  TOTAL_EXPENDITURES = 'Total Expenditures'
  PER_PUPAL_REVENUE = 'Per Pupil Revenue'
  PER_PUPAL_EXPENDITURES = 'Per Pupil Expenditures'
  FEDERAL_REVENUE= "Percent Federal Revenue"
  STATE_REVENUE= "Percent State Revenue"
  LOCAL_REVENUE= "Percent Local Revenue"
  INSTRUCTIONAL_EXPENDITURES= "Percent Instructional Expenditures"
  SUPPORT_EXPENDITURES= "Percent Support Services Expenditures"
  OTHER_EXPENDITURES= "Percent Other Expenditures"
  UNCATEGORIZED_EXPENDITURES= "Percent Uncategorized Expenditures"
  
  REVENUE_SOURCES = [
    FEDERAL_REVENUE,
    STATE_REVENUE,
    LOCAL_REVENUE
  ]

  REVENUE = [
    TOTAL_REVENUE,
    PER_PUPAL_REVENUE
  ]

  ALL_REVENUE_DATA_TYPES = REVENUE + REVENUE_SOURCES

  EXPENDITURES_SOURCES = [
    INSTRUCTIONAL_EXPENDITURES,
    SUPPORT_EXPENDITURES,
    OTHER_EXPENDITURES,
    UNCATEGORIZED_EXPENDITURES
  ]

  EXPENDITURES = [
    TOTAL_EXPENDITURES,
    PER_PUPAL_EXPENDITURES
  ]

  SOURCES_OF_REVENUE = {
    key: 'RevenueSources',
    data_keys: REVENUE_SOURCES  
  }
  
  SOURCES_OF_EXPENDITURES = {
    key: 'ExpenditureSources',
    data_keys: EXPENDITURES_SOURCES
  }

  ALL_EXPENDITURES_DATA_TYPES = EXPENDITURES + EXPENDITURES_SOURCES

  FINANCE_DATA_TYPES = ALL_REVENUE_DATA_TYPES + ALL_EXPENDITURES_DATA_TYPES

  CHAR_CACHE_ACCESSORS = [
    {
      key: TOTAL_REVENUE,
      formatting:  [:to_f, :round],
      type: 'large_dollar_amt'
    },
    {
      key: PER_PUPAL_REVENUE,
      formatting: [:to_f, :round, :dollars],
      type: 'dollar_ratio'
    },
    {
      key: FEDERAL_REVENUE,
      formatting: [:to_f, :round],
      type: 'pie_slice'
    },
    {
      key: STATE_REVENUE,
      formatting: [:to_f, :round],
      type: 'pie_slice'
    },
    {
      key: LOCAL_REVENUE,
      formatting: [:to_f, :round],
      type: 'pie_slice'
    },
    {
      key: TOTAL_EXPENDITURES,
      formatting:  [:to_f, :round],
      type: 'large_dollar_amt'
    },
    {
      key: PER_PUPAL_EXPENDITURES,
      formatting: [:to_f, :round, :dollars],
      type: 'dollar_ratio'
    },
    {
      key: INSTRUCTIONAL_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'pie_slice'
    },
    {
      key: SUPPORT_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'pie_slice'
    },
    {
      key: OTHER_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'pie_slice'
    },
    {
      key: UNCATEGORIZED_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'pie_slice'
    }
  ]

end