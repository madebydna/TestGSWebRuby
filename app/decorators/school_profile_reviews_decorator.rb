# This module isn't a Draper decorator, but probably should be
# I was having issues with Draper that I believe were resolved after I already changed this to be a non-draper decorator
#
# This decorator is meant to decorate a SchoolReviews object (hence plural form of Review in the name)
# It might be better if it decorated an enumerable collection of reviews that extends the ReviewCalculations module,
# since that's more generic than the SchoolReviews class

# This decorator knows how to use the (5 star rating) review answer distribution map, and turn it into an array
# that our bar chart code (using google charts) knows how to understand
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

  # Given a hash for review answer distribution, turn it into an array that will be used to render a bar chart
  def to_bar_chart_array
    star_distribution = {
      5 => 0,
      4 => 0,
      3 => 0,
      2 => 0,
      1 => 0,
    }.merge(five_star_rating_score_distribution)

    chart = [
      ['Stars', 'count']
    ]

    star_distribution.each_with_object(chart) do |(star, number_of_occurrences), chart_array|
      label = h.pluralize(star, 'star', 'stars')
      chart_array << [ label, number_of_occurrences ]
    end
  end

end