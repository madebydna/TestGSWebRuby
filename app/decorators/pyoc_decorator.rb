class PyocDecorator < Draper::Decorator

  include ActionView::Helpers

  decorates :school_cache
  delegate_all

  include GradeLevelConcerns
  include SchoolTypeConcerns
  include LevelCodeConcerns
  include MapIconConcerns
  include SpanishPdfConcerns


end