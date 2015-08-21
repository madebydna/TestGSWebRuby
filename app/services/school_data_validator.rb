module SchoolDataValidator

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

    # high school graduation rate BEGIN
    'sd_4_year_high_school_graduation_rate_White',
    'sd_4_year_high_school_graduation_rate_Asian',
    'sd_4_year_high_school_graduation_rate_Native_American_or_Native_Alaskan',
    'sd_4_year_high_school_graduation_rate_Pacific_Islander',
    'sd_4_year_high_school_graduation_rate_All_students',
    'sd_4_year_high_school_graduation_rate_Multiracial',
    'sd_4_year_high_school_graduation_rate_Filipino',
    'sd_4_year_high_school_graduation_rate_Hispanic',
    'sd_4_year_high_school_graduation_rate_African_American',

    'sd_4_year_high_school_graduation_rate_White_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Asian_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Native_American_or_Native_Alaskan_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Pacific_Islander_sortable_asc',
    'sd_4_year_high_school_graduation_rate_All_students_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Multiracial_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Filipino_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Hispanic_sortable_asc',
    'sd_4_year_high_school_graduation_rate_African_American_sortable_asc',
    # high school graduation rate END

    #Percent of students who meet UC/CSU entrance requirements BEGIN
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_White',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Asian',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Native_American_or_Native_Alaskan',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Pacific_Islander',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_All_students',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Multiracial',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Filipino',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Hispanic',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_African_American',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Male',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Female',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_economically_disadvantaged',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Students_with_disabilities',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_General_Education_students',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Economically_disadvantaged',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Limited_English_proficient',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_limited_English_proficient',

    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_White_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Asian_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Native_American_or_Native_Alaskan_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Pacific_Islander_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_All_students_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Multiracial_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Filipino_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Hispanic_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_African_American_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Male_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Female_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_economically_disadvantaged_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Students_with_disabilities_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_General_Education_students_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Economically_disadvantaged_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Limited_English_proficient_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_limited_English_proficient_sortable_asc'
    #Percent of students who meet UC/CSU entrance requirements END
  ]

  def is_valid_school_data_field?(field)
    VALID_SCHOOL_DATA_FIELDS.include?(field)
  end

end
