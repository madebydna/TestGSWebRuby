class SchoolSearchResultDecorator < SchoolProfileDecorator
  #Might want to refactor this out of SchoolProfileDecorator
  #if some SchoolProfileDecoratorCode is unused

  include NumberUtils

  #ToDo change to decorates :SchoolSearchResult when code is pushed
  decorates :school_search_result
  delegate_all

  def decorated_school_type
    if type == 'Charter'
      'Public charter'
    elsif type == 'Public'
      'Public district'
    else
      'Private'
    end
  end

  def distance
    faster_number_with_precision(school_search_result.distance, 2) #distance with precision of 2
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
