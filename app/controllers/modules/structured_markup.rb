module StructuredMarkup
  module ControllerConcerns
    extend ActiveSupport::Concern

    protected

    def json_ld_hash 
      @_json_ld_hash ||= {}.merge(default_json_ld_hash)
    end

    def json_ld_hash=(hash)
      @_json_ld_hash = hash
    end

    def default_json_ld_hash
      StructuredMarkup.organization_hash
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
end
