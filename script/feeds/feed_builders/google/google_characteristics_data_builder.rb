# Will not work
# Need to reformat to new feeds builder format
# Instead of using the old one

module Feeds
  class GoogleCharacteristicsDataBuilder
    include Feeds::FeedConstants

    def self.characteristics_format(characteristics_data_set, universal_id, model)
      @model = model
      METRICS_MAPPING.map do | cm |
        build_data(cm, characteristics_data_set, universal_id)
      end.flatten if characteristics_data_set
    end

    def self.build_data(characteristics_map, characteristics_data_set, universal_id)
      char_data_set = characteristics_data_set.find{ |cds| characteristics_map[:key] == cds.first }
      send(characteristics_map[:method], char_data_set.second, universal_id, characteristics_map[:data_type] ) if char_data_set
    end

    def self.students_with_limited_english_proficiency(data, universal_id, data_type=nil)
      if data.present? && data.first && data.first[value_var]
        options = {}
        options[:value] = data.first[value_var].to_f.round(3)
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('percent-students-with-limited-english-proficiency', options)
      end
    end

    def self.straight_text_value(data, universal_id, data_type)
      if data.present? && data.first && data.first[value_var]
        options = {}
        options[:value] = data.first[value_var]
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure(data_type, options)
      end
    end

    def self.teacher_data(data, universal_id, data_type)
      if data.present? && data.first && data.first[value_var]
        options = {}
        options[:value] = data.first[value_var].to_f.round(1)
        options[:data_type] = data_type
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('teacher-data', options)
      end
    end

    def self.enrollment(data, universal_id, data_type)
      data.compact!
      hash = data.find { | h | h['grade'].blank? } if data.present?
      if hash && hash[value_var]
        options = {}
        options[:value] = hash[value_var].to_i
        options[:year] = hash['year']
        options[:universal_id] = universal_id
        build_structure('enrollment', options)
      end
    end

    def self.ethnicity(data, universal_id, data_type)
      data.compact!
      if data.present?
        data.map do |d|
          if d && d[value_var]
            options = {}
            options[:value] = d[value_var].to_f.round(1)
            options[:name] = race_mapping(d['original_breakdown'], d['breakdown'])
            options[:year] = d['year']
            options[:universal_id] = universal_id
            build_structure('ethnicity', options)
          end
        end
      end
    end

    def self.race_mapping(b1, b2)
      race = b1 || b2
      race == 'African American' ? 'Black' : race
    end

    def self.percent_economically_disadvantaged(data, universal_id, data_type=nil)
      if data.present? && data.first && data.first[value_var]
        options = {}
        options[:value] = data.first[value_var].to_f.round(3)
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('percent-economically-disadvantaged', options)
      end
    end

    def self.free_or_reduced_lunch_program(data, universal_id, data_type)
      if data.present? && data.first && data.first[value_var]
        options = {}
        options[:value] = data.first[value_var].to_f.round(1)
        options[:year] = data.first['year']
        options[:universal_id] = universal_id
        build_structure('percent-free-and-reduced-price-lunch', options)
      end
    end

    def self.student_teacher_ratio(data, universal_id, data_type)
      if data.present? && data.first && data.first[value_var]
        options = {}
        options[:value] = data.first[value_var].to_f.round(1)
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

    def self.value_var
      @model.downcase+'_value'
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
