module SchoolDataValidation
  def log_data_rejection(state,school,data_type,reason)
    Rails.logger.error("SCHOOL CACHE VALIDATION: School #{state}-#{school}'s #{data_type} data was rejected: #{reason}'")
    GSLogger.error(:school_cache, nil, vars: {state: state, school_id: school, data_type: data_type},
                   message: "SCHOOL CACHE VALIDATION: School #{state}-#{school}'s #{data_type} data was rejected: #{reason}'")
  end
end