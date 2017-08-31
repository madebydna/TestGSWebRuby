module DistrictDataValidation
  def log_data_rejection(state,district,data_type,reason)
    Rails.logger.error("DISTRICT CACHE VALIDATION: District #{state}-#{district}'s #{data_type} data was rejected: #{reason}'")
  end
end