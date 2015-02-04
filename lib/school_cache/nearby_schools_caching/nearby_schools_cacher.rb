class NearbySchoolsCaching::NearbySchoolsCacher < Cacher
  CACHE_KEY = 'nearby_schools'
  SCHOOL_COUNT = 5


  def query_results
    @query_results ||= (
      school.schools_by_distance_cache SCHOOL_COUNT
    )
  end

  def build_hash_for_cache
    rval = []
    query_results.each do |school_obj|
      rval << build_nearby_school_hash(school_obj)
    end
    rval
  end

  def build_nearby_school_hash(school_obj)
    school_profile_decorator = SchoolProfileDecorator.decorate(school_obj)
    school_reviews_global = SchoolReviews.calc_review_data(school_obj.reviews)
    review_score = school_reviews_global.rating_averages.overall.avg_score
    review_count = school_reviews_global.rating_averages.overall.counter
    {
        id: school_obj.id,
        name: school_obj.name,
        city: school_obj.city,
        state: school_obj.state,
        gs_rating: school_obj.great_schools_rating.present? ? school_obj.great_schools_rating : 'nr',
        type: school_obj.type,
        level: school_profile_decorator.process_level,
        review_score: review_score,
        review_count: review_count
    }
  end

  def self.listens_to?(data_type)
    :school_location == data_type
  end

end