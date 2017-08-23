require 'set'
module SchoolProfiles
  class Courses
    include Qualaroo

    SUBJECT_ORDER = %w(ela_index stem_index hss_index fl_index arts_index health_index vocational_hands_on_index)
    SUBJECT_RATING_SUPPRESSION = %w(arts_index health_index vocational_hands_on_index)

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @data_types = [
        'Course Enrollment',
        'Advanced Course Rating'
      ]
    end

    def qualaroo_module_link
      qualaroo_iframe(:advanced_coursework, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def faq
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.advanced_courses.faq'),
                        content: I18n.t(:content_html, scope: 'lib.advanced_courses.faq'))
    end

    def most_recent_rating_hash
      @_most_recent_rating_hash ||=
        advanced_course_ratings
        .having_no_breakdown
        .most_recent
    end

    def rating_year
      @_rating_year ||= most_recent_rating_hash.try(:source_year)
    end

    def rating
      @_rating ||= most_recent_rating_hash.try(:school_value)
    end

    def advanced_course_ratings
      @_advanced_course_ratings ||= (
        (data['Advanced Course Rating'] || [])
        .map { |h| GsdataCaching::GsDataValue.from_hash(h) }
        .extend(GsdataCaching::GsDataValue::CollectionMethods)
      )
    end

    def narration
      return nil unless rating.present? && (1..10).cover?(rating.to_i)
      key = '_' + ((rating.to_i / 2) + (rating.to_i % 2)).to_s + '_html'
      I18n.t(key, scope: 'lib.advanced_courses.narration', default: I18n.db_t(key, default: key)).html_safe
    end


    # Output data format:
    #
    # {
    #   "STEM" => [
    #     {
    #       rating: 8,
    #       courses: [ "Math A" ]
    #     }
    #   ],
    #   "Foreign Language" => [
    #     {
    #       rating: 9,
    #       courses: [ "Foo", "Bar" ]
    #
    #     }
    #
    #   ]
    # }
    def course_enrollments_and_ratings
      course_ratings_hash = course_subject_group_ratings.each_with_object({}) do |(readable_subject, rating), accum|
        subject_key = readable_subject.downcase.gsub(' ', '_')
        accum[subject_key] = rating
      end
      SUBJECT_ORDER.each_with_object({}) do |snake_case_subject, accum|
        courses = courses_by_subject[snake_case_subject] || []
        if SUBJECT_RATING_SUPPRESSION.include?(snake_case_subject)
          rating = nil
        else
          rating = course_ratings_hash[snake_case_subject]
        end
        translated_subject = t(snake_case_subject.gsub(/ index/i, ''))
        accum[translated_subject] = {
            'courses' => courses.map { |h| h['name'] },
            'rating' => rating
        }
      end
    end

    def data
      @school_cache_data_reader.gsdata_data(*@data_types)
    end

    def courses_by_subject
      # Course Enrollment data format:
      # [
      #   { 
      #     breakdowns: Math A
      #     breakdown_tags: course,stem_index,
      #     school_value: '8'
      #     source_year: 2015
      #     source_name: California Department of Education
      #   }
      #   {
      #     breakdowns: Marketing and Business Fundamentals712
      #     breakdown_tags: business_index,course,vocational_hands_on_index
      #     school_value: '57'
      #     source_year: 2015
      #     source_name: California Department of Education
      #   }
      # ]
      #
      # Output format:
      # {
      #   stem_index: [
      #     { 
      #       name: 'Math A',
      #       source: 'California Dept. of Education',
      #       year: 2016
      #     }
      #   ],
      #   business_index: [
      #     {
      #       name: 'Marketing and Business Fundamentals712',
      #       source: 'California Dept. of Education',
      #       year: 2016
      #     }
      #   ],
      #   vocational_hands_on_index: [
      #     {
      #       name: 'Marketing and Business Fundamentals712',
      #       source: 'California Dept. of Education',
      #       year: 2016
      #     }
      #   ]
      # }
      @courses_by_subject ||= (
      (data['Course Enrollment'] || [])
        .map { |h| GsdataCaching::GsDataValue.from_hash(h) }
        .select { |dv| dv.breakdown_tags =~ /advanced/ }
        .each_with_object({}) do |dv, accum|
          # tags that match *_index
          subjects = dv.breakdown_tags
            .split(',')
            .select { |s| s[-6..-1] == '_index' } 

          subjects.each do |subject|
            accum[subject] ||= []
            accum[subject] << {
              'name' => dv.breakdowns,
              'source' => dv.source_name,
              'year' => dv.source_year
            }
          end
        end
      )
    end

    # Input data format:
    # [
    #   {
    #     "breakdowns" => "Arts Index",
    #     "breakdown_tags" => "course_subject_group",
    #     "school_value" => "2",
    #     "source_year" => 2015,
    #     "source_name" => "California Department of Education"
    #   },
    #   {
    #     "breakdowns" => "FL Index",
    #     "breakdown_tags" => "course_subject_group",
    #     "school_value" => "9",
    #     "source_year" => 2015,
    #     "source_name" => "California Department of Education"
    #   }
    # ]
    #
    # Output data format:
    #
    # {
    #   "Arts Index" => 9,
    #   "FL Index" => 2
    # }
    def course_subject_group_ratings
      @_course_subject_group_ratings ||= (
        course_ratings_subjects.each_with_object({}) do |dv, accum|
          subject = dv.breakdowns
          accum[subject] = dv.school_value.to_i
        end
      )
    end

    # Input data example:
    # [
    #   {
    #     "breakdowns" => "Arts Index",
    #     "breakdown_tags" => "course_subject_group",
    #     "school_value" => "2",
    #     ...
    #   },
    #   {
    #     "breakdowns" => "Foo",
    #     "breakdown_tags" => "male",
    #     "school_value" => "9",
    #     ...
    #   }
    # ]
    #
    # Output data example:
    #
    # [
    #   {
    #     "breakdowns" => "Arts Index",
    #     "breakdown_tags" => "course_subject_group",
    #     "school_value" => "2",
    #     ...
    #   }
    # ]
    def course_ratings_subjects
      @_course_ratings_subjects ||= (
        max_year = rating_year || advanced_course_ratings.year_of_most_recent
        advanced_course_ratings.select { |h| h.breakdown_tags == 'course_subject_group' && h.source_year == max_year }
      )
    end

    # Output data example:
    #
    # {
    #   'GreatSchools College Readiness Rating' => {['GreatSchools', 2016'] => ['The college readiness rating...']}
    #   'Advanced courses' => {['California Department of Education', 2016] => [ 'Arts', 'Math']}
    # }
    def sources
      subject_sources = courses_by_subject.each_with_object({}) do |(subject_key, courses), accum|
        unique_sources = courses.map { |c| [db_t(c['source']), c['year'].to_i] }.uniq
        unique_sources.each do |source|
          accum[source] ||= Set.new
          accum[source] << t(subject_key)
        end
      end
      subject_hash = { t(:advanced_courses) => subject_sources }
      rating_hash = if rating.present?
                      {t(:rating_title) => {['GreatSchools', rating_year] => t(:rating_description)}}
                    else
                      {}
                    end
      rating_hash.merge(subject_hash)
    end

    def t(s)
      I18n.t(s, scope:'lib.advanced_courses', default: s)
    end

    def db_t(s)
      I18n.db_t(s, default: s)
    end

    def visible?
      rating.present? || (courses_by_subject.present? && courses_by_subject.map { |_,v| v.size }.reduce(:+) > 0)
    end
  end
end
