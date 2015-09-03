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
    'sd_4_year_high_school_graduation_rate_White_2013',
    'sd_4_year_high_school_graduation_rate_Asian_2013',
    'sd_4_year_high_school_graduation_rate_Native_American_or_Native_Alaskan_2013',
    'sd_4_year_high_school_graduation_rate_Pacific_Islander_2013',
    'sd_4_year_high_school_graduation_rate_All_students_2013',
    'sd_4_year_high_school_graduation_rate_Multiracial_2013',
    'sd_4_year_high_school_graduation_rate_Filipino_2013',
    'sd_4_year_high_school_graduation_rate_Hispanic_2013',
    'sd_4_year_high_school_graduation_rate_African_American_2013',
    'sd_4_year_high_school_graduation_rate_Male_2013',
    'sd_4_year_high_school_graduation_rate_Female_2013',
    'sd_4_year_high_school_graduation_rate_Not_economically_disadvantaged_2013',
    'sd_4_year_high_school_graduation_rate_Students_with_disabilities_2013',
    'sd_4_year_high_school_graduation_rate_General_Education_students_2013',
    'sd_4_year_high_school_graduation_rate_Economically_disadvantaged_2013',
    'sd_4_year_high_school_graduation_rate_Limited_English_proficient_2013',
    'sd_4_year_high_school_graduation_rate_Not_limited_English_proficient_2013',

    'sd_4_year_high_school_graduation_rate_White_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Asian_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Native_American_or_Native_Alaskan_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Pacific_Islander_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_All_students_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Multiracial_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Filipino_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Hispanic_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_African_American_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Male_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Female_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Not_economically_disadvantaged_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Students_with_disabilities_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_General_Education_students_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Economically_disadvantaged_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Limited_English_proficient_2013_sortable_asc',
    'sd_4_year_high_school_graduation_rate_Not_limited_English_proficient_2013_sortable_asc',
    # high school graduation rate END

    #Percent of students who meet UC/CSU entrance requirements BEGIN
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_White_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Asian_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Native_American_or_Native_Alaskan_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Pacific_Islander_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_All_students_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Multiracial_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Filipino_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Hispanic_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_African_American_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Male_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Female_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_economically_disadvantaged_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Students_with_disabilities_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_General_Education_students_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Economically_disadvantaged_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Limited_English_proficient_2014',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_limited_English_proficient_2014',

    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_White_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Asian_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Native_American_or_Native_Alaskan_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Pacific_Islander_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_All_students_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Multiracial_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Filipino_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Hispanic_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_African_American_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Male_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Female_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_economically_disadvantaged_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Students_with_disabilities_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_General_Education_students_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Economically_disadvantaged_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Limited_English_proficient_2014_sortable_asc',
    'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements_Not_limited_English_proficient_2014_sortable_asc'
    #Percent of students who meet UC/CSU entrance requirements END
  ]

  def is_valid_school_data_field?(field)
    VALID_SCHOOL_DATA_FIELDS.include?(field)
  end

end
