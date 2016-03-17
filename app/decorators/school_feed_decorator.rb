class SchoolFeedDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :school_cache
  delegate_all

  include GradeLevelConcerns


end