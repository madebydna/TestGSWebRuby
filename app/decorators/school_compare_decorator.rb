class SchoolCompareDecorator < SchoolProfileDecorator

  decorates :school
  delegate_all


  ################################ Characteristics ################################

  def characteristics
    return @characteristics if @characteristics
    @characteristics = JSON.parse(SchoolCache.for_school('characteristics',id,state).value)
  end

  def enrollment
    characteristics_data['Enrollment'].first['school_value']
  end

  ################################ Reviews ################################

  def reviews_snapshot
    return @reviews_snapshot if @reviews_snapshot
    @reviews_snapshot = JSON.parse(SchoolCache.for_school('reviews_snapshot',id,state).value)
  end

  def star_rating
    reviews_snapshot['avg_star_rating']
  end

  def num_reviews
    reviews_snapshot['num_reviews']
  end

  ################################# Programs ##################################

  def programs
    return @programs if @programs
    @programs = JSON.parse(SchoolCache.for_school('esp_responses',id,state).value)
  end

end