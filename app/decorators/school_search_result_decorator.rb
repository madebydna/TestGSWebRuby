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

  def decorated_school_type
    if type == 'Charter'
      'Public charter'
    elsif type == 'Public'
      'Public district'
    else
      'Private'
    end
  end

  def google_map_data_point
    begin
      map_points = {
        name: name,
        id: id,
        street: street,
        city: city,
        state: state,
        zipcode: zipcode,
        schoolType: decorated_school_type,
        preschool: preschool?,
        gradeRange: process_level,
        fitScore: fit_score,
        maxFitScore: max_fit_score,
        gsRating: overall_gs_rating || 0,
        on_page: (on_page),
        strongFit: strong_fit?,
        okFit: ok_fit?
      }
    rescue NameError => e
      puts e.message
      puts 'School Does not have method/solr attribute'
      nil
    else
      yield map_points if block_given?
      map_points
    end
  end
end
