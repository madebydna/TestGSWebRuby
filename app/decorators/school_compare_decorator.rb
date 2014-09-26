class SchoolCompareDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :school_cache
  delegate_all

  attr_accessor :prepped_ethnicities

  include GradeLevelConcerns
  include RatingsIconConcerns
  include SchoolTypeConcerns
  include FitScoreConcerns
  include SubscriptionConcerns

  def ethnicity_label_icon
    'fl square js-comparePieChartSquare'
  end

  def school_page_url
    h.school_url(school_cache)
  end

  def zillow_formatted_url
    h.zillow_url(school_cache)
  end

  def follow_this_school
    h.render 'shared/add_to_my_school_list_form', school: school_cache, driver: 'Compare'
  end

end