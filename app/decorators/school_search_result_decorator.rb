class SchoolSearchResultDecorator < SchoolProfileDecorator
  #Might want to refactor this out of SchoolProfileDecorator
  #if some SchoolProfileDecoratorCode is unused

  #ToDo change to decorates :SchoolSearchResult when code is pushed
  decorates :school_search_result
  delegate_all

  STRONG_FIT_CUTOFF = 0.666
  OK_FIT_CUTOFF = 0.333

  def strong_fit?
    max_fit_score > 0 && (fit_score / max_fit_score.to_f) >= STRONG_FIT_CUTOFF
  end

  def ok_fit?
    max_fit_score > 0 && fit_score > 0 && (fit_score / max_fit_score.to_f) >= OK_FIT_CUTOFF && (fit_score / max_fit_score.to_f) < STRONG_FIT_CUTOFF
  end

  def weak_fit?
    max_fit_score > 0 && fit_score > 0 && (fit_score / max_fit_score.to_f) < OK_FIT_CUTOFF
  end

  def google_map_data_point
    map_points = {
      name: self.name,
      id: self.id,
      lat: self.latitude,
      lng: self.longitude,
      street: self.street,
      city: self.city,
      state: self.state,
      zipcode: self.zipcode,
      schoolType: self.type,
      preschool: self.preschool?,
      gradeRange: self.grades[0] + " - " + self.grades[-1],
      fitScore: self.fit_score,
      maxFitScore: self.max_fit_score,
      gsRating: self.overall_gs_rating || 0,
      on_page: (self.on_page)
    }

    yield map_points if block_given?

    map_points
  end
end
