module StudentTypes

  class << self

    def all
      @_all ||= all_as_strings.map(&:to_sym)
    end

    def all_as_strings
      @_all_as_strings ||= datatype_breakdown_map.values.map(&:downcase)
    end

    def all_datatypes
      @_all_datatypes ||= datatype_breakdown_map.keys.map(&:to_sym)
    end

    def datatype_to_breakdown(datatype)
      datatype_breakdown_map[datatype] || datatype
    end

    def general_education_breakdown_label
      @_general_education_breakdown_label ||= 'General-Education students'
    end

    # Student types aren't necessarily the same name as their breakdowns so we map
    # the datatype (used above to get the data) to its breakdown here.
    def datatype_breakdown_map
      @_datatype_breakdown_map ||= {
        'Students who are not economically disadvantaged'=> 'Not economically disadvantaged',
        'Students with disabilities' => 'Students with disabilities',
        'Not special education' => general_education_breakdown_label,
        'Students participating in free or reduced-price lunch program'=> 'Economically disadvantaged',
        'English learners' => 'Limited English proficient',
        'Not English learners' => 'Not limited English proficient',
        'Migrant' => 'Migrant'
      }
    end

  end
end
