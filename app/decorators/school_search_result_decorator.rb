class SchoolSearchResultDecorator < SchoolProfileDecorator
  #Might want to refactor this out of SchoolProfileDecorator
  #if some SchoolProfileDecoratorCode is unused

  #ToDo change to decorates :SchoolSearchResult when code is pushed
  decorates :school_search_result
  delegate_all
end
