class NearbySchoolsCaching::NearbySchoolsCacher < Cacher
  CACHE_KEY = 'nearby_schools'
  SCHOOL_COUNT = 5

  def query_results
    @query_results ||= (
      school.schools_by_distance SCHOOL_COUNT
    )
  end

  def build_hash_for_cache
    @review_results_obj = {}
    @decorator_results_obj = {}
    rval = []
    query_results.each do |school_obj|
      rval << build_nearby_school_hash(school_obj)
    end
    rval
  end

  def build_nearby_school_hash(school_obj)
    {
        id: school_obj.id,
        name: school_obj.name,
        city: school_obj.city,
        state: school_obj.state,
        gs_rating: school_obj.great_schools_rating.present? ? school_obj.great_schools_rating : 'nr',
        type: school_obj.type,
        level: school_decorator_obj(school_obj),
        review_score: school_review_avg_score(school_obj),
        review_count: school_review_count(school_obj)
    }
  end

  def school_review_count(school_obj)
    school_review_obj(school_obj).rating_averages.overall.counter
  end

  def school_review_avg_score(school_obj)
    school_review_obj(school_obj).rating_averages.overall.avg_score
  end

  def school_review_obj(school_obj)
    begin
      @review_results_obj[school_obj] ||=
        (SchoolReviews.calc_review_data(school_obj.reviews))
    rescue StandardError => e
      puts e
    end

  end

  def school_decorator_obj(school_obj)
    begin
      @decorator_results_obj[school_obj] ||=
        (SchoolProfileDecorator.decorate(school_obj)).process_level
    rescue StandardError => e
      puts e
    end
  end

  def self.listens_to?(data_type)
    :school_location == data_type
  end

end
