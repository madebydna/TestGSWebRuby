module CommunityProfiles
  class Toc

    TOC_CONFIG = {
      academic_progress: { label: 'academic_progress', anchor: 'academic_progress' },
      academics: { label: 'academics', anchor: 'academics' },
      advanced_courses: { label: 'advanced_courses', anchor: 'advanced_courses' },
      award_winning_schools: { label: 'award_winning_schools', anchor: 'award-winning-schools' },
      calendar: { label: 'calendar', anchor: 'calendar' },
      cities: { label: 'cities', anchor: 'cities' },
      community_resources: { label: 'community_resources', anchor: 'mobility' },
      distance_learning: { label: 'distance_learning', anchor: 'distance-learning' },
      finance: { label: 'district_finances', anchor: 'finance' },
      nearby_homes_for_sale: { label: 'nearby_homes_for_sale_and_rent', anchor: 'homes-and-rentals' },
      neighboring_cities: { label: 'neighboring_cities', anchor: 'neighboring-cities' },
      reviews: { label: 'reviews', anchor: 'reviews' },
      school_districts: { label: 'districts', anchor: 'districts' },
      schools: { label: 'schools', anchor: 'schools' },
      student_demographics: { label: 'student_demographics', anchor: 'students' },
      student_progress: { label: 'student_progress', anchor: 'student_progress' },
      teachers_staff: { label: 'teachers_staff', anchor: 'teachers-staff' }
    }

    def initialize(csa_module: nil, school_districts: nil, academics: nil, advanced_courses: nil, student_demographics: nil, reviews: nil, neighboring_cities: nil, teachers_staff: nil, finance: nil, growth_rating: nil, distance_learning: nil)
      @csa_module = csa_module
      @school_districts = school_districts
      @academics = academics
      @advanced_courses = advanced_courses
      @student_demographics = student_demographics
      @reviews = reviews
      @neighboring_cities = neighboring_cities
      @teachers_staff = teachers_staff
      @finance = finance
      @growth_rating = growth_rating
      @distance_learning = distance_learning
    end

    def state_toc
      toc_items = [:schools, :award_winning_schools, :academics, :student_demographics, :cities, :school_districts, :reviews]

      generate_toc(toc_items)
    end

    def city_toc
      toc_items = [:schools, :school_districts, :community_resources, :nearby_homes_for_sale, :reviews, :neighboring_cities]

      generate_toc(toc_items)
    end

    def district_toc
      toc_items = [:schools, :distance_learning, :academics, :academic_progress, :student_progress, :advanced_courses, :student_demographics, :teachers_staff, :calendar, :finance, :community_resources, :nearby_homes_for_sale, :reviews]

      generate_toc(toc_items)
    end

    def generate_toc(toc_items)
      toc_items.delete(:award_winning_schools) unless @csa_module
      toc_items.delete(:school_districts) if @school_districts&.empty?
      toc_items.delete(:academics) unless @academics && @academics[:data].present?
      toc_items.delete(:distance_learning) unless @distance_learning.present?
      toc_items.delete(:student_demographics) unless @student_demographics&.students_demographics.present?
      toc_items.delete(:reviews) if @reviews&.empty?
      toc_items.delete(:neighboring_cities) if @neighboring_cities&.empty?
      toc_items.delete(:advanced_courses) if @advanced_courses && @advanced_courses[:courses].empty?
      toc_items.delete(:teachers_staff) if @teachers_staff && @teachers_staff[:sources].empty?
      toc_items.delete(:finance) if @finance&.empty?

      if @growth_rating && (@growth_rating['key'] == 'academic_progress')
        toc_items.delete(:student_progress)
      elsif @growth_rating && (@growth_rating['key'] == 'student_progress')
        toc_items.delete(:academic_progress)
      else
        toc_items.delete(:student_progress)
        toc_items.delete(:academic_progress)
      end

      toc_items.compact.map { |item| TOC_CONFIG[item] }
    end
  end
end
