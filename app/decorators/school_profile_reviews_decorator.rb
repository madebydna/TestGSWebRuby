module SchoolProfileReviewsDecorator

  def self.decorate(school_reviews, view_context)
    school_reviews.extend self
    school_reviews.instance_variable_set(:@view_context, view_context)
    school_reviews
  end

  def h
    @view_context
  end

  def see_all_reviews_phrase
    phrase = 'See '
    phrase << 'all ' if number_of_reviews_with_comments > 1
    phrase << h.pluralize(number_of_reviews_with_comments, 'Review', 'Reviews')
    phrase
  end

  def to_bar_chart_array
    star_distribution = {
      5 => 0,
      4 => 0,
      3 => 0,
      2 => 0,
      1 => 0,
    }.merge(score_distribution)

    chart = [
      ['Stars', 'count']
    ]

    star_distribution.each_with_object(chart) do |(star, number_of_occurrences), chart_array|
      label = h.pluralize(star, 'star', 'stars')
      chart_array << [ label, number_of_occurrences ]
    end
  end

end