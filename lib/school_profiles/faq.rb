module SchoolProfiles
  class Faq
    attr_reader :cta, :content

    def initialize(cta:, content:, element_type:)
      @cta = cta
      @content = content
      @element_type = element_type
    end
  end
end