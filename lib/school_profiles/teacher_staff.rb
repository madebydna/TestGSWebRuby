module SchoolProfiles
  class TeacherStaff

    attr_reader :school_cache_data_reader

    CHAR_CACHE_ACCESSORS = [
        {
            :data_key => 'Ratio of teacher salary to total number of teachers',
            :visualization => :person_bar_viz, #something that means number
            :formatting => [:round]
        },
        {
            :data_key => 'Percentage of full time teachers who are certified',
            :visualization => :person_bar_viz, #something that means number
            :formatting => [:round, :percent]
        },
        {
            :data_key => 'Ratio of students to full time counselors',
            :visualization => :person_bar_viz, #something that means number
            :formatting => [:round]
        },
        {
            :data_key => 'Ratio of students to full time teachers',
            :visualization => :person_bar_viz, #something that means number
            :formatting => [:round]
        }
    ].freeze

    def initialize(school_cache_data_reader)
      @school_cache_data_reader = school_cache_data_reader
    end

    def included_data_types
      @_included_data_types ||=
        CHAR_CACHE_ACCESSORS.map { |mapping| mapping[:data_key] }
    end

    def data_type_hashes
      hashes = school_cache_data_reader.gsdata_data(
          *included_data_types
      )
      return [] if hashes.blank?
      hashes = hashes.map do |key, array|
        GSLogger.error(:misc, nil,
                       message:"Failed to find unique data point for data type #{key} in the gsdata cache",
                       vars: {school: {state: @school_cache_data_reader.school.state,
                                       id: @school_cache_data_reader.school.id}
                       }) if array.size > 1
        hash = array.first
        hash['data_type'] = key
        hash
      end
      hashes.sort_by { |o| included_data_types.index( o[:data_key]) }
    end

  end
end

