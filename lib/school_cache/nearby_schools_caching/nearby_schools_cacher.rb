class NearbySchoolsCaching::NearbySchoolsCacher < Cacher
  CACHE_KEY = 'nearby_schools'
  SCHOOL_COUNT = 5

  def build_hash_for_cache
    {
      NearbySchoolsCaching::Lists::ClosestSchools::NAME =>
      NearbySchoolsCaching::Lists::ClosestSchools.results(school, limit: SCHOOL_COUNT)
    }
  end

  def self.listens_to?(data_type)
    :school_location == data_type
  end

end
