class NearbySchoolsCaching::NearbySchoolsCacher < Cacher
  CACHE_KEY = 'nearby_schools'
  SCHOOL_COUNT = 5

  # Lists must map exactly to methods in this class. These methods
  # should return the result of a methodology's #results method or the
  # concatentation of multiple methodologies' #results.
  DEFAULT_LIST = :closest_schools
  COLLECTION_LISTS = Hash.new([]).merge({
    14 => [:closest_top_then_top_nearby_schools],
  })

  def build_hash_for_cache
    # Using shard because it is a lowercase symbol
    hash_structure_for_collections(school.collection_ids)
  end

  def self.listens_to?(data_type)
    [:school_location, :ratings].include? data_type
  end

  protected

  def hash_structure_for_collections(collection_ids)
    lists_for_collections(collection_ids).each_with_object({}) do |list, h|
      h[list] = send(list)
    end
  end

  # Returns an array of all the unique lists attached to the given
  # collection_ids
  def lists_for_collections(collection_ids)
    [DEFAULT_LIST] | collection_ids.map { |id| COLLECTION_LISTS[id] }.flatten
  end

  def closest_schools
    opts = { limit: SCHOOL_COUNT }
    methodologies::ClosestSchools.results(school, opts)
  end

  def closest_top_then_top_nearby_schools
    ratings = [
      { data_type_id: 174, breakdown_id: 1 },
      { data_type_id: 174, breakdown_id: 9 }, # 9 is low income students
    ]
    closest_top_opts = {
      limit: 1,
      minimum: 8, # minimum rating
      ratings: ratings,
    }
    closest_top_schools = methodologies::ClosestTopSchools.results(school, closest_top_opts)
    school_ids_to_exclude = closest_top_schools.map { |s| s[:id] }.join(',')
    top_nearby_opts = {
      limit: 6,
      radius: radius_based_on_level, # miles
      ratings: ratings,
      school_ids_to_exclude: school_ids_to_exclude,
    }
    top_nearby_schools = methodologies::TopNearbySchools.results(school, top_nearby_opts)
    unified_list = (closest_top_schools + top_nearby_schools).compact
    add_review_data_to_nearby_school_hashes(unified_list) if unified_list.present?
    unified_list
  end

  def add_review_data_to_nearby_school_hashes(hashes)
    school_ids = hashes.map { |h| h[:id] }
    review_datas = Review.average_five_star_rating(school.state, school_ids)
    hashes.each do |hash|
      review_data_for_school = review_datas[hash[:id]]
      hash.merge!(review_data_for_school.to_h) if review_data_for_school
    end
  end

  def radius_based_on_level
    if school.level_code.include? 'h'
      5 # miles
    else
      2 # miles
    end
  end

  def methodologies
    NearbySchoolsCaching::Methodologies
  end
end
