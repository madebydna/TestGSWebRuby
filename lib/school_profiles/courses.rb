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
    #   "STEM Index" => [
    #     {
    #       rating: "8",
    #       courses: [
    #         {
    #           "name" => "Math A"
    #           "source_year" => 2015,
    #           "source_name" => "California Department of Education"
    #           "school_value" => "162"
    #         }
    #       ]
    #     }
    #   ],
    #   "FL Index" => "2"
    # }
    def course_enrollments_and_ratings
      course_subject_group_ratings.each_with_object({}) do |(readable_index, rating), accum|
        index_key = readable_index.downcase.gsub(' ', '_')
        courses = course_enrollments_by_course_index[index_key]
        accum[readable_index.gsub(/ index/i, '')] = {
          'courses' => courses,
          'rating' => rating
        }
      end
    end

    def data
      @school_cache_data_reader.gsdata_data(*@data_types)
    end

    def course_enrollments_by_course_index
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
      @course_enrollments_by_course_index ||= (
        array = (data['Course Enrollment'] || [])
          .each_with_object([]) do |h, accum|
            # tags that match *_index
            tags = h['breakdown_tags'].split(',').select { |t| t[-6..-1] == '_index' } 
            tags.each do |t|
              accum << h.merge(
                'breakdown_tags' => t,
                'name' => h['breakdowns']
              ).except('breakdowns')
            end
          end
        array.group_by { |h| h['breakdown_tags'] }
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
    #   "Arts Index" => "9",
    #   "FL Index" => "2"
    # }
    def course_subject_group_ratings
      @_course_subject_group_ratings ||= (
        (data['Advanced Course Rating'] || [])
        .select { |h| h['breakdown_tags'] == 'course_subject_group'}
        .each_with_object({}) do |course, hash|
          index = course['breakdowns']
          hash[index] = course['school_value']
        end
      )
    end

  end
end
