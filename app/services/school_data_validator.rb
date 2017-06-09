module SchoolDataValidator


  BREAKDOWN_LIST = [ 'White', 'Asian', 'Native_American_or_Native_Alaskan', 'Pacific_Islander', 'All_students', 'Multiracial',
    'Filipino', 'Hispanic', 'African_American', 'Male', 'Female', 'Not_economically_disadvantaged', 'Students_with_disabilities',
    'General_Education_students', 'Economically_disadvantaged', 'Limited_English_proficient', 'Not_limited_English_proficient'
  ]


  def is_valid_school_data_field?(field)
    VALID_SCHOOL_DATA_FIELDS.include?(field)
  end

  class << self
    def valid_school_data_fields
      valid_grad_rates + valid_a_through_g + valid_caaspp
    end

    def valid_grad_rates
      BREAKDOWN_LIST.each_with_object([]) do |breakdown, valid_list|
        ['2013', '2014'].each do | year |
          [nil, '_sortable_asc'].each do | sort |
            valid_list << "sd_4_year_high_school_graduation_rate_#{breakdown}_#{year}#{sort}"
          end
        end
      end
    end

    def valid_a_through_g
      BREAKDOWN_LIST.each_with_object([]) do |breakdown, valid_list|
        ['2014'].each do | year |
          [nil, '_sortable_asc'].each do | sort |
            valid_list << "sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_#{breakdown}_#{year}#{sort}"
          end
        end
      end
    end

    def valid_caaspp
      (BREAKDOWN_LIST + ['Students_without_disabilities']).each_with_object([]) do |breakdown, valid_list|
        ['Math', 'English_Language_Arts'].each do | subject |
          ['2015','2016'].each do | year |
            [nil, '_sortable_asc'].each do | sort |
              valid_list << "sd_California_Assessment_of_Student_Performance_and_Progress_CAASPP_#{subject}_#{breakdown}_#{year}#{sort}"
            end
          end
        end
      end
    end

  end

  VALID_SCHOOL_DATA_FIELDS = [
    'document_type',
    'contentKey',
    'sd_collection_id',
    'sd_school_id',
    'sd_school_name',
    'sd_school_type',
    'sd_grades',
    'sd_school_grade_level',
    'sd_school_grade_range',
    'sd_school_active',
    'sd_school_database_state',
    'sd_overall_gs_rating',
    'sd_sorted_gs_rating_asc',
  ] + valid_school_data_fields

end
