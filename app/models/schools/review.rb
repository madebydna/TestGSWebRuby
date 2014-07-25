class Review
  attr_accessor :who, :status, :rating, :review_topic_id, :created, :updated, :comments, :review_type, :parents, :teachers, :principal, :id, :member_id

  def self.all (school = nil)
    #return @list_of_reviews if defined?

    school_ratings = SchoolRating.where(school_id: school.id, state: school.state).all
    topical_reviews = TopicalSchoolReview.where(school_id: school.id, state: school.state).all
    #school_ratings
    # take two lists and join / merge
    reviews_join(school_ratings, topical_reviews)
    #@last_updated = last_update_date

    #default sort
    #reviews_sort_by_date_desc
  end


  #def self.filtered_reviews (school, options = {})
  #  reviews = SchoolRating.filter school, options
  #  topical = TopicalSchoolReview.filter school, options
  #  reviews_join reviews, topical
  #end

  def self.reviews_join(reviews, topical)
    reviews_map = []
    reviews_map += reviews.map do |review|
      normalize_review review
    end

    reviews_map += topical.map do |review|
      normalize_topical review
    end
    reviews_map
  end

  def self.normalize_review(review)
    r = Review.new
    r.who = review.who
    r.status = review.status
    r.rating = (review.quality == 'decline') ? ((review.p_overall == 'decline') ? '0' : review.p_overall ) : review.quality
    r.review_topic_id = nil
    r.created = review.posted.to_datetime
    r.updated = review.posted.to_datetime
    r.comments = review.comments
    r.review_type = 'schoolReview'
    r.parents = review.parents
    r.teachers = review.teachers
    r.principal = review.principal
    r.member_id = review.member_id
    r.id = review.id
    r
  end

  def self.normalize_topical(review)
    r = Review.new
    r.who = review.who
    r.status = review.status
    r.rating = ((review.rating == 'decline') ? '0' : review.rating)
    r.review_topic_id = review.review_topic_id
    r.created = review.created
    r.updated = review.updated
    r.comments = review.comments
    r.review_type = :'topicalReview'
    r.member_id = review.member_id
    r.id = review.id
    r
  end

  def self.reviews_fetch(school=nil, options={})
    list_of_reviews = all(school)
    case options[:order_results_by]
      when 'oldToNew'
        list_of_reviews.sort_by!(&:created)
      when 'ratingsHighToLow'
        list_of_reviews = list_of_reviews.sort do |a,b|
          (b.rating <=> a.rating).nonzero? ||
            (b.created <=> a.created)
        end
      when 'ratingsLowToHigh'
        list_of_reviews = list_of_reviews.sort do |a,b|
          (a.rating <=> b.rating).nonzero? ||
            (b.created <=> a.created)
        end
      else
        list_of_reviews.sort_by!(&:created).reverse!
    end

    unless options[:group_to_filter_by] == 'all' || options[:group_to_filter_by].nil? || options[:group_to_filter_by].empty?
      list_of_reviews = list_of_reviews.select { |review| review.who == options[:group_to_filter_by] }
    end
    list_of_reviews
  end
end
