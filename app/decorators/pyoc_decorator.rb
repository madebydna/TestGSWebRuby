class PyocDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :school_cache
  delegate_all

  include GradeLevelConcerns
  include SchoolTypeConcerns
  include LevelCodeConcerns


end