module TopRatedSchools
  def create_top_rated_schools(state, city)
    (1..5).each do |nearby_school_number|
      shard = state.downcase.to_sym
      s = FactoryGirl.build(:alameda_high_school, city: city, state: state.to_s, name: "Nearby School #{nearby_school_number}")
      s.on_db(shard).save
      metadata = FactoryGirl.build(:overall_rating_school_metadata, school_id: s.id, meta_value: nearby_school_number + 5)
      metadata.on_db(shard).save
    end
  end
end