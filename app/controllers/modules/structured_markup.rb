module StructuredMarkup
  # number of reviews to be added to json-ld hash
  REVIEW_COUNT = 4

  module ControllerConcerns
    extend ActiveSupport::Concern

    protected

    def json_ld_data
      prepare_json_ld
      return json_ld_array
    end

    def add_json_ld(array_or_other_obj)
      if array_or_other_obj.is_a?(Array)
        json_ld_array.concat(array_or_other_obj)
      else
        json_ld_array.push(array_or_other_obj)
      end
    end

    def add_json_ld_breadcrumb(text:, url:)
      unless existing_json_ld_breadcrumbs
        add_json_ld(StructuredMarkup.breadcrumbs_as_json_ld([]))
      end
      existing_json_ld_breadcrumbs << {
        "@type" => "ListItem",
        "position" => existing_json_ld_breadcrumbs.length + 1,
        "item" => {
          "@id" => StructuredMarkup.ensure_https(url),
          "name" => text,
          "image" => StructuredMarkup.ensure_https(url)
        }
      }
    end

    def existing_json_ld_breadcrumbs
      json_ld_array.find { |h| h['@type'] == 'BreadcrumbList'}&.fetch('itemListElement')
    end

    def prepare_json_ld
      # noop. override to implement
    end

    private

    # internal data structure, do not use outside of this module
    def json_ld_array
      @_json_ld_array ||= default_json_ld_data
    end

    def default_json_ld_data
      []
    end
  end

  def self.organization_hash
    {
      "@context" => "https://schema.org",
      "@type" => "Organization",
      "name" => "GreatSchools",
      "url" => "https://www.greatschools.org/",
      "logo" => "https://www.greatschools.org/images/greatschools-logo.png",
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

  def self.reviews_array(school_reviews, on_demand=false)
    reviews = on_demand ? school_reviews.having_comments.take(REVIEW_COUNT) : school_reviews.having_comments
    reviews.map do |review|
      review = SchoolProfileReviewDecorator.decorate(review)
      markup = {
          "@type" => "Review",
          "datePublished" => review.created,
          "reviewBody" => review.comment,
          "author" => review.user_type
      }
      if review.numeric_answer_value
        markup['reviewRating'] = {
            '@type' => 'Rating',
            'bestRating' => '5',
            'ratingValue' => review.numeric_answer_value,
            'worstRating' => '1'
        }
      end
      markup
    end
  end

  def self.home_breadcrumb_text
    'GreatSchools'
  end

  def self.state_breadcrumb_text(state)
    if state == 'DC'
      'District of Columbia'
    else
      States.state_name(state).gs_capitalize_words
    end
  end

  def self.city_breadcrumb_text(state:, city:)
    text =
      if state == 'DC'
        'Washington, D.C.'
      else
        city
      end
    text.gs_capitalize_words
  end

  def self.ensure_https(url)
    url_local = url
    if ENV_GLOBAL['force_ssl'].present? && ENV_GLOBAL['force_ssl'].to_s == 'true'
      uri = URI.parse(url)
      uri.scheme = 'https'
      url_local = uri.to_s
    end
    url_local
  end

  def self.breadcrumbs_as_json_ld(crumbs)
    crumbs.map.with_index do |(name, url), index|
      {
        "@type" => "ListItem",
        "position" => index + 1,
        "item" => {
          "@id" => ensure_https(url),
          "name" => name,
          "image" => ensure_https(url)
        }
      }
    end
    {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => crumbs
    }
  end

  def self.breadcrumbs_hash(school)
    urlHelperMethods = Class.new
      .include(Rails.application.routes.url_helpers)
      .include(UrlHelper)
      .new

    urlHelperMethods.default_url_options = {trailing_slash: true}

    crumbs = [
      [
        state_breadcrumb_text(school.state),
        urlHelperMethods.send(:state_url, urlHelperMethods.send(:state_params, school.state)),
      ],
      [
        city_breadcrumb_text(state: school.state, city: school.city),
        urlHelperMethods.send(:city_url, urlHelperMethods.send(:city_params, school.state, school.city))
      ],
      [
        'Schools',
        urlHelperMethods.send(:search_city_browse_url, urlHelperMethods.send(:city_params, school.state, school.city))
      ],
      [
        school.name,
        urlHelperMethods.send(:school_url, school)
      ]
    ].map.with_index do |(name, url), index|
      {
        "@type" => "ListItem",
        "position" => index + 1,
        "item" => {
          "@id" => ensure_https(url),
          "name" => name,
          "image" => ensure_https(url)
        }
      }
    end
    {
      "@context" => "https://schema.org",
      "@type" => "BreadcrumbList",
      "itemListElement" => crumbs
    }
  end

  def self.school_hash(school, gs_rating, school_reviews = nil, reviews_on_demand=false)
    hash = {}
    hash["@context"] = "https://schema.org"
    hash["@type"] = "School"
    hash['name'] = school.name
    hash['description'] = StructuredMarkup.description(school: school, gs_rating: gs_rating)
    hash['address'] = {
      '@type' => 'PostalAddress',
      'streetAddress' => school.street,
      'addressLocality' => school.city,
      'addressRegion' => school.state,
      'postalCode' => school.zipcode
    }
    hash['telephone'] = school.phone if school.phone.present?
    same_as = []
    same_as << school.facebook_url if school.facebook_url
    same_as << school.home_page_url if school.home_page_url
    hash['sameAs'] = same_as unless same_as.empty?

    return hash unless school_reviews

    hash['aggregateRating'] = aggregate_rating_hash(school_reviews) if school_reviews.number_of_5_star_ratings > 0

    if school_reviews.number_of_active_reviews > 0
      arr_of_reviews = reviews_array(school_reviews, reviews_on_demand)
      # Limit to single review when no aggregateRating (required by Google Rich Results Validator)
      hash['review'] = hash.has_key?('aggregateRating') ? arr_of_reviews : arr_of_reviews.take(1)
    end

    hash
  end

  def self.description(school:, gs_rating:)
    snippet ||= "#{school.name} is a #{school.type} school" unless school.name.empty? || school.type.empty?
    if snippet
      levels_str = GradeLevelConcerns.human_readable_level(school.level)
      if levels_str && !levels_str.include?('Ungraded')
        levels_description = levels_str.length > 2 ? "grades #{levels_str}" : "grade #{levels_str}"
        snippet << " that serves #{levels_description}"
      end
      if gs_rating.present?
        snippet << ". It has received a GreatSchools rating of #{gs_rating} out of 10 based on academic quality."
      else
        snippet << ". This school does not qualify for a GreatSchools rating because there is not sufficient academic data to generate one."
      end
    end
    snippet.presence
  end
end
