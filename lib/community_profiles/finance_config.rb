module CommunityProfiles::FinanceConfig
  TOTAL_REVENUE = 'total revenue'
  TOTAL_EXPENDITURES = 'total expenditures'
  PER_PUPAL_REVENUE = 'per pupal revenue'
  PER_PUPAL_EXPENDITURES = 'per pupal expenditures'
  FEDERAL_REVENUE= "percent federal revenue"
  STATE_REVENUE= "percent state revenue"
  LOCAL_REVENUE= "percent local revenue"
  INSTRUCTIONAL_EXPENDITURES= "percent instructional expenditures"
  SUPPORT_EXPENDITURES= "percent support services expenditures"
  OTHER_EXPENDITURES= "percent other expenditures"
  UNCATEGORIZED_EXPENDITURES= "percent uncategorized expenditures"
  
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

  ALL_EXPENDITURES_DATA_TYPES = EXPENDITURES + EXPENDITURES_SOURCES

  FINANCE_DATA_TYPES = ALL_REVENUE_DATA_TYPES + ALL_EXPENDITURES_DATA_TYPES

  CHAR_CACHE_ACCESSORS = [
    {
      key: TOTAL_REVENUE,
      formatting:  [:to_f, :round, :dollars],
      type: 'dollar_amt'
    },
    {
      key: PER_PUPAL_REVENUE,
      formatting: [:to_f, :round],
      type: 'ratio'
    },
    {
      key: FEDERAL_REVENUE,
      formatting: [:to_f, :round],
      type: 'percent_bar'
    },
    {
      key: STATE_REVENUE,
      formatting: [:to_f, :round],
      type: 'percent_bar'
    },
    {
      key: LOCAL_REVENUE,
      formatting: [:to_f, :round],
      type: 'percent_bar'
    },
    {
      key: TOTAL_EXPENDITURES,
      formatting:  [:to_f, :round, :dollars],
      type: 'dollar_amt'
    },
    {
      key: PER_PUPAL_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'ratio'
    },
    {
      key: INSTRUCTIONAL_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'percent_bar'
    },
    {
      key: SUPPORT_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'percent_bar'
    },
    {
      key: OTHER_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'percent_bar'
    },
    {
      key: UNCATEGORIZED_EXPENDITURES,
      formatting: [:to_f, :round],
      type: 'percent_bar'
    }
  ]

end