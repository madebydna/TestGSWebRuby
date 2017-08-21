module Feeds
  class CharacteristicsDataBuilder

    # this is a white list of keys we are looking for - executes a method to handle type of data
    CHARACTERISTICS_MAPPING = [
        {
            key: 'Enrollment',
            method: 'enrollment'
        },
        {
            key: 'Ethnicity',
            method: 'ethnicity'
        },
        {
            key: 'Students participating in free or reduced-price lunch program',
            method: 'free_or_reduced_lunch_program'
        },
        {
            key: 'Head official name',
            method: 'straight_text_value',
            data_type: 'head-official-name'
        },
        {
            key: 'Head official email address',
            method: 'straight_text_value',
            data_type: 'head-official-email'
        },
        {
            key: 'English learners',
            method: 'students_with_limited_english_proficiency'
        },
        {
            key: 'Student teacher ratio',
            method: 'student_teacher_ratio'
        },
        {
            key: 'Students who are economically disadvantaged',
            method: 'percent_economically_disadvantaged'
        },
        {
            key: 'Average years of teacher experience',
            method: 'teacher_data',
            data_type: 'average teacher experience years'
        },
        {
            key: 'Average years of teaching in district',
            method: 'teacher_data',
            data_type: 'average years teaching in district'
        },
        {
            key: 'Percent classes taught by highly qualified teachers',
            method: 'teacher_data',
            data_type: 'percent classes taught by highly qualified teachers'
        },
        {
            key: 'Percent classes taught by non-highly qualified teachers',
            method: 'teacher_data',
            data_type: 'percent classes taught by non highly qualified teachers'
        },
        {
            key: 'Percentage of teachers in their first year',
            method: 'teacher_data',
            data_type: 'percent teachers in first year'
        },
        {
            key: 'Teaching experience 0-3 years',
            method: 'teacher_data',
            data_type: 'percent teachers with 3 years or less experience'
        },
        {
            key: 'at least 5 years teaching experience',
            method: 'teacher_data',
            data_type: 'percent teachers with at least 5 years experience'
        },
        {
            key: "Bachelor's degree",
            method: 'teacher_data',
            data_type: 'percent teachers with bachelors degree'
        },
        {
            key: "Doctorate's degree",
            method: 'teacher_data',
            data_type: 'percent teachers with doctorate degree'
        },
        {
            key: "Master's degree",
            method: 'teacher_data',
            data_type: 'percent teachers with masters degree'
        },
        {
            key: "Master's degree or higher",
            method: 'teacher_data',
            data_type: 'percent teachers with masters or higher'
        },
        {
            key: 'Teachers with no valid license',
            method: 'teacher_data',
            data_type: 'percent teachers with no valid license'
        },
        {
            key: 'Other degree',
            method: 'teacher_data',
            data_type: 'percent teachers with other degree'
        },
        {
            key: 'Teachers with valid license',
            method: 'teacher_data',
            data_type: 'percent teachers with valid license'
        }
    ].freeze

    def self.characteristics_format(characteristics_data_set, universal_id)
      char_arr = []
      characteristics_data_set.each do | cds |
        char_arr << build_data(cds.first, cds.second, universal_id)
      end
      char_arr.flatten
    end

    def self.build_data(key, data, universal_id)
      characteristic = CHARACTERISTICS_MAPPING.find{ |characteristics| characteristics[:key] == key }
      characteristic ? send(characteristic[:method], data, universal_id, characteristic[:data_type] ) : capture_misses(key)
    end

    def self.students_with_limited_english_proficiency(data, universal_id, data_type=nil)
      if data && data.first && data.first['school_value']
        options = {}
        options[:value] = data.first['school_value'].to_f.round(3)
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('percent-students-with-limited-english-proficiency', options)
      end
    end

    def self.straight_text_value(data, universal_id, data_type)
      if data && data.first && data.first['school_value']
        options = {}
        options[:value] = data.first['school_value']
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure(data_type, options)
      end
    end

    def self.teacher_data(data, universal_id, data_type)
      if data && data.first && data.first['school_value']
        options = {}
        options[:value] = data.first['school_value'].to_f.round(1)
        options[:data_type] = data_type
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('teacher-data', options)
      end
    end

    def self.enrollment(data, universal_id, data_type)
      hash = data.find { | h | h['grade'].blank? } if data
      if hash && hash['school_value']
        options = {}
        options[:value] = hash['school_value'].to_i
        options[:year] = hash['year']
        options[:universal_id] = universal_id
        build_structure('enrollment', options)
      end
    end

    def self.ethnicity(data, universal_id, data_type)
      if data
        arr = []
        data.each do |d|
          if d && d['school_value']
            options = {}
            options[:value] = d['school_value'].to_f.round(1)
            options[:name] = d['original_breakdown'] || d['breakdown']
            options[:year] = d['year']
            options[:universal_id] = universal_id
            arr << build_structure('ethnicity', options)
          end
        end
        arr
      end
    end

    def self.free_or_reduced_lunch_program(data, universal_id, data_type)
      if data && data.first && data.first['school_value']
        options = {}
        options[:value] = data.first['school_value'].to_f.round(1)
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('percent-free-and-reduced-price-lunch', options)
      end
    end

    #TODO find sample in db to see what type of rounding needed
    def self.student_teacher_ratio(data, universal_id, data_type)
      if data && data.first && data.first['school_value']
        options = {}
        options[:value] = data.first['school_value'].to_f.round(1)
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('student-teacher-ratio', options)
      end
    end

    def self.single_data_object(name, value, attrs=nil)
      SingleDataObject.new(name, value, attrs)
    end

    def self.capture_misses(key)
      single_data_object(key, 'missed')
    end

    def self.build_structure(key, options={})
      value = options[:value]
      universal_id = options[:universal_id]
      name = options[:name]
      year = options[:year]
      data_type = options[:data_type]

      arr = []
      arr << single_data_object('universal-id', universal_id) if universal_id
      arr << single_data_object('name', name) if name
      arr << single_data_object('value', value) if value
      arr << single_data_object('year', year) if year
      arr << single_data_object('data-type', data_type) if data_type

      single_data_object(key, arr) if arr
    end
  end

end
