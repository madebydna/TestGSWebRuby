module CachedGsdataMethods

  DISCIPLINE_FLAG = 'Discipline Flag'
  ABSENCE_FLAG = 'Absence Flag'

  def gsdata
    cache_data['gsdata'] || {}
  end

  def discipline_flag?
    @_discipline_flag ||= (
    flag_data_value = discipline_attendance_data_values[DISCIPLINE_FLAG]
    flag_data_value.present? && flag_data_value.school_value == '1'
    )
  end

  def attendance_flag?
    @_attendance_flag ||= (
    flag_data_value = discipline_attendance_data_values[ABSENCE_FLAG]
    flag_data_value.present? && flag_data_value.school_value == '1'
    )
  end

  def discipline_attendance_data_values
    @_discipline_attendance_data_values ||= (
    gsdata.slice(DISCIPLINE_FLAG, ABSENCE_FLAG).each_with_object({}) do |(data_type_name, array_of_hashes), output_hash|
      most_recent_all_students = array_of_hashes
                                     .map { |hash| GsdataCaching::GsDataValue.from_hash(hash.merge(data_type: data_type_name)) }
                                     .extend(GsdataCaching::GsDataValue::CollectionMethods)
                                     .having_no_breakdown
                                     .most_recent
      output_hash[data_type_name] = most_recent_all_students if most_recent_all_students
    end
    )
  end

  def max_source_date_valid
    @_max_source_date_valid ||= begin
      all_gsdata_objs = gsdata.values.map do |array_of_hashes|
        array_of_hashes.map { |hash| GsdataCaching::GsDataValue.from_hash(hash) }
      end.flatten.extend(GsdataCaching::GsDataValue::CollectionMethods)
      most_recent = all_gsdata_objs.most_recent
      most_recent.source_date_valid if most_recent
    end
  end
end