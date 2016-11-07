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

    def add_json_ld(hash)
      json_ld_hash << hash
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

  def self.school_hash(school)
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
    hash
  end
end
