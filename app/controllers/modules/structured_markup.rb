module StructuredMarkup
  module ControllerConcerns
    extend ActiveSupport::Concern

    protected

    def json_ld_hash 
      @_json_ld_hash ||= default_json_ld_hash
    end

    def json_ld_hash=(hash)
      @_json_ld_hash = hash
    end

    def add_json_ld(array_or_other_obj)
      if array_or_other_obj.is_a?(Array)
        json_ld_hash.concat(array_or_other_obj)
      else
        json_ld_hash.push(array_or_other_obj)
      end
    end

    def default_json_ld_hash
      [StructuredMarkup.organization_hash]
    end
  end

  def self.organization_hash
    {
      "@context" => "http://schema.org",
      "@type" => "Organization",
      "name" => "GreatSchools",
      "url" => "http://www.greatschools.org/",
      "logo" => "http://www.greatschools.org/images/greatschools-logo.png",
      "sameAs" => [
        "https://www.facebook.com/greatschools",
        "https://www.twitter.com/greatschools",
        "https://pinterest.com/greatschools/",
        "https://www.youtube.com/GreatSchools",
        "https://www.instagram.com/greatschools/",
        "https://en.wikipedia.org/wiki/GreatSchools"
      ]
    }
  end

  def self.aggregate_rating_hash(school_reviews)
    {
      "@type" => "AggregateRating",
      "ratingValue" => school_reviews.average_5_star_rating,
      "bestRating" => 5,
      "worstRating" => 1,
      "reviewCount" => school_reviews.number_of_active_reviews,
      "ratingCount" => school_reviews.number_of_5_star_ratings
    }
  end

  def self.reviews_array(school_reviews)
    school_reviews.having_comments.map do |review|
      review = SchoolProfileReviewDecorator.decorate(review)
      {
        "@type" => "Review",
        "datePublished" => review.created,
        "reviewBody" => review.comment,
        "reviewRating" => {
          "@type" => "Rating",
          "bestRating" => "5",
          "ratingValue" => review.numeric_answer_value,
          "worstRating" => "1"
        }   
      }
    end
  end

  def self.school_hash(school, school_reviews = nil)
    hash = {}
    hash["@context"] = "http://schema.org"
    hash["@type"] = "School"
    hash['name'] = school.name
    hash['address'] = {
      'streetAddress' => school.street,
      'addressLocality' => school.city,
      'addressRegion' => school.state,
      'postalCode' => school.zipcode
    }
    same_as = []
    same_as << school.facebook_url if school.facebook_url
    same_as << school.home_page_url if school.home_page_url
    hash['sameAs'] = same_as unless same_as.empty?

    if school_reviews && school_reviews.number_of_5_star_ratings > 0
      hash['aggregateRating'] = aggregate_rating_hash(school_reviews)
    end
    if school_reviews && school_reviews.number_of_active_reviews > 0
      hash['review'] = reviews_array(school_reviews)
    end

    hash
  end
end
