class DistrictFeedDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :district_cache
  delegate_all

  include GradeLevelConcerns


end