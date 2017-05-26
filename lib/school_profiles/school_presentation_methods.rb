module SchoolProfiles
  module SchoolPresentationMethods
    def self.extend(s)
      unless s.singleton_class.ancestors.include?(SchoolPresentationMethods)
        s.extend SchoolPresentationMethods
      end
    end

    def type
      super.gs_capitalize_first
    end

    def address
      "#{street}, #{city}, #{state} #{zipcode}"
    end

    def city_state
      [city, state].join(', ')
    end
  end
end
