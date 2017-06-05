module SchoolProfiles
  class Faq
    attr_reader :cta, :content

    def initialize(cta:, content:)
      @cta = cta
      @content = content
    end
  end
end