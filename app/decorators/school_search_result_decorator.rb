class SchoolSearchResultDecorator < SchoolProfileDecorator
  #Might want to refactor this out of SchoolProfileDecorator
  #if some SchoolProfileDecoratorCode is unused

  #ToDo change to decorates :SchoolSearchResult when code is pushed
  decorates :school_search_result
  delegate_all

  def strong_fit?
    max_fit_score > 0 && (fit_score / max_fit_score) > 0.5
  end

  def ok_fit?
    max_fit_score > 0 && fit_score > 0 && (fit_score / max_fit_score) <= 0.5
  end
end
