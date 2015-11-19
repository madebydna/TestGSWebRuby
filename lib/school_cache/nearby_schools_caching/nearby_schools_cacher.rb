class NearbySchoolsCaching::NearbySchoolsCacher < Cacher
  CACHE_KEY = 'nearby_schools'
  SCHOOL_COUNT = 5

  def build_hash_for_cache
    {
      closest_schools: closest_schools,
      closest_top_then_top_nearby_schools: closest_top_then_top_nearby_schools,
    }
  end

  def self.listens_to?(data_type)
    :school_location == data_type
  end

  protected

  def closest_schools
    opts = { limit: SCHOOL_COUNT }
    methodologies::ClosestSchools.results(school, opts)
  end

  def closest_top_then_top_nearby_schools
    ratings = [
      { data_type_id: 174, breakdown_id: 1 },
      { data_type_id: 174, breakdown_id: 8 },
    ]
    closest_top_opts = {
      limit: 1,
      minimum: 8, # minimum rating
      ratings: ratings,
    }
    top_nearby_opts = {
      limit: 4,
      radius: 2, # miles
      ratings: ratings,
    }
    (
      methodologies::ClosestTopSchools.results(school, closest_top_opts) +
      methodologies::TopNearbySchools.results(school, top_nearby_opts)
    )
  end

  def methodologies
    NearbySchoolsCaching::Methodologies
  end
end
