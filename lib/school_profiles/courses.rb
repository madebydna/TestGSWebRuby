require 'set'
module SchoolProfiles
  class Courses
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @data_types = [
        'Course Enrollment',
        'Advanced Course Rating'
      ]
    end

    def rating
      @_rating ||=
        ((data['Advanced Course Rating'] || [])
          .find { |h| h['breakdowns'].nil? } || {})['school_value']
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
      course_subject_group_ratings
        .each_with_object({}) do |(readable_subject, rating), accum|
          subject_key = readable_subject.downcase.gsub(' ', '_')
          courses = (courses_by_subject[subject_key] || []).map { |h| h['name'] }
          translated_subject = t(readable_subject.gsub(/ index/i, ''))
          accum[translated_subject] = {
            'courses' => courses,
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
      #       enrollment: 8
      #     }
      #   ],
      #   business_index: [
      #     {
      #       name: 'Marketing and Business Fundamentals712',
      #       enrollment: 57
      #     }
      #   ],
      #   vocational_hands_on_index: [
      #     {
      #       name: 'Marketing and Business Fundamentals712',
      #       enrollment: 57
      #     }
      #   ]
      # }
      @courses_by_subject ||= (
      (data['Course Enrollment'] || [])
        .select { |h| h['breakdown_tags'] =~ /advanced/ }
        .each_with_object({}) do |h, accum|
          # tags that match *_index
          subjects = h['breakdown_tags']
            .split(',')
            .select { |s| s[-6..-1] == '_index' } 

          subjects.each do |subject|
            accum[subject] ||= []
            accum[subject] << {
              'name' => h['breakdowns']
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
        course_ratings_subjects.each_with_object({}) do |hash, accum|
          subject = hash['breakdowns']
          accum[subject] = hash['school_value'].to_i
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
        (data['Advanced Course Rating'] || [])
          .select { |h| h['breakdown_tags'] == 'course_subject_group'}
      )
    end

    # Output data example:
    #
    # {
    #   ['California Department of Education', 2016] => [ 'Arts', 'Math']
    # }
    def sources
      (
        course_ratings_subjects.each_with_object({}) do |hash, accum|
          source_info = [hash['source_name'], hash['source_year'].to_i]
          accum[source_info] ||= Set.new
          accum[source_info] << t(hash['breakdowns'].gsub(' Index', ''))
        end
      )
    end

    def t(s)
      I18n.t(s, scope:'lib.advanced_courses')
    end

  end
end
