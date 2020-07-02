module CommunityProfiles
  class TeachersStaff

    attr_reader :data_reader
    attr_accessor :sources

    OTHER_STAFF_DATA =
      [
        {
          key: 'Percent of Nurse Staff',
          formatting:  [:to_f, :round, :percent],
          type: 'other_staff'
        },
        {
          key: 'Percent of Psychologist Staff',
          formatting:  [:to_f, :round, :percent],
          type: 'other_staff'
        },
        {
          key: 'Percent of Social Worker Staff',
          formatting:  [:to_f, :round, :percent],
          type: 'other_staff'
        },
        {
          key: 'Percent of Law Enforcement Staff',
          formatting:  [:to_f, :round, :percent],
          type: 'other_staff'
        },
        {
          key: 'Percent of Security Guard Staff',
          formatting:  [:to_f, :round, :percent],
          type: 'other_staff'
        }
      ]

    MAIN_STAFF_DATA =
      [
        {
          key: 'Ratio of students to full time teachers',
          formatting: [:to_f, :round],
          type: 'ratio'
        },
        {
          key: 'Ratio of students to full time counselors',
          formatting: [:to_f, :round],
          type: 'ratio'
        },
        {
          key: 'Percentage of teachers with less than three years experience',
          formatting: [:to_f, :invert_using_one_hundred, :round],
          type: 'percent_bar'
        },
        {
          key: 'Percentage of full time teachers who are certified',
          formatting: [:to_f, :round],
          type: 'percent_bar'
        },
        {
          key: 'Ratio of teacher salary to total number of teachers',
          formatting:  [:to_f, :round, :dollars],
          type: 'dollar_amt'
        }
      ]

    CACHE_ACCESSORS = MAIN_STAFF_DATA + OTHER_STAFF_DATA

    def initialize(data_reader)
      @data_reader = data_reader
      @sources = []
    end

    def main_staff_data_types
      @_main_staff_data_types ||=
        MAIN_STAFF_DATA.map { |mapping| mapping[:key] }
    end

    def other_staff_data_types
      @_other_staff_data_types ||=
        OTHER_STAFF_DATA.map { |mapping| mapping[:key] }
    end

    def included_data_types
      @_included_data_types ||=
        CACHE_ACCESSORS.map { |mapping| mapping[:key] }
    end

    def data_values
      { state: data_reader.district.state,
        district_id: data_reader.district.district_id,
        main_staff: main_staff_data,
        other_staff: {
          name: data_label_district('other staff resources'),
          tooltip: data_label_district('other staff tooltip'),
          data: other_staff_data
        },
        sources: sources_data
      }
    end

    def main_staff_hash
      @main_staff_hash ||= data_reader.decorated_metrics_datas(*main_staff_data_types)
    end

    def main_staff_data
      @main_staff_data ||= begin
        return [] if main_staff_hash.empty?
        MAIN_STAFF_DATA.reduce([]) do |memo, config|
          if value = get_max_year(main_staff_hash[config[:key]])
            memo << base_data_for(config).merge(MainStaffData.new(value, config[:formatting]).to_h)
          end
          memo
        end
      end
    end

    def other_staff_hash
      @other_staff_hash ||= data_reader.decorated_metrics_datas(*other_staff_data_types)
    end

    def other_staff_data
      @other_staff_data ||= begin
        return [] if other_staff_hash.empty?
        OTHER_STAFF_DATA.reduce([]) do |memo, config|
          name = config[:key]
          full_time_value = select_latest_breakdown_value(other_staff_hash[name], "full-time")
          part_time_value = select_latest_breakdown_value(other_staff_hash[name], "part-time")
          if full_time_value || part_time_value
            memo << base_data_for(config).merge(
              OtherStaffData.new(full_time_value, part_time_value, config[:formatting]).to_h
            )
          end
          memo
        end
      end
    end

    def sources_data
      (main_staff_data + other_staff_data).map {|h| extract_source(h) }
    end

    private

    def base_data_for(config)
      {
        name: data_label(config[:key]),
        tooltip: data_label_info_text(config[:key]),
        type: config[:type]
      }
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.teachers_staff', default: I18n.db_t(key, default: key))
    end

    def data_label_district(key)
      I18n.t(key.to_sym, scope: 'lib.teachers_staff.district', default: I18n.db_t(key, default: key))
    end

    def data_label_info_text(key)
      I18n.t(key.to_sym, scope: 'lib.teachers_staff.data_point_info_texts.district', default: '')
    end

    def extract_source(item)
      {
        name: item[:name],
        description: item[:tooltip],
        source_and_year: "#{item[:source]}, #{item[:year]}"
      }
    end

    def select_latest_breakdown_value(array, breakdown)
      return nil unless array.present?
      all_values = array.select {|v| v.breakdown == breakdown }
      get_max_year(all_values)
    end

    def get_max_year(array)
      return nil unless array.present?
      array.max_by(&:source_date_valid)
    end

  end
end