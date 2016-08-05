module SchoolProfiles
  class Hero
    include DefHasPredicates
    include ActionView::Helpers::UrlHelper

    attr_reader :school, :school_cache_data_reader

    delegate :gs_rating, :students_enrolled, :five_star_rating, :number_of_active_reviews, to: :school_cache_data_reader
    delegate :name, :address, :type, :phone, :home_page_url, to: :school, prefix: :school
    delegate :district, to: :school

    # Makes has_district?,  has_school_address?, etc
    def_has_predicates :school_phone, :grade_range, :school_home_page_url, :district, :school_address, :gs_rating

    def initialize(school, school_cache_data_reader:)
      self.school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def school=(school)
      raise ArgumentError('School must be provided') if school.nil?
      SchoolProfiles::SchoolPresentationMethods.extend(school)
      school.extend(GradeLevelConcerns)
      @school = school
    end

    def grade_range_label
      return 'Grade' unless has_grade_range?
      if grade_range.include?('-') || grade_range.include?(',')
        'Grades'
      else
        'Grade'
      end
    end

    def grade_range
      @_grade_range ||= school.process_level
    end

    def school_home_page_link
      return unless has_school_home_page_url?
      link_to(school_home_page_url, school_home_page_url)
    end

    def district_name
      return unless has_district?
      school.district.name
    end
  end
end
