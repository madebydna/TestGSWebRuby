module StateDataValidation
  def log_data_rejection(state, data_type, reason)
    Rails.logger.error("STATE CACHE VALIDATION: State #{state} - #{data_type} data was rejected: #{reason}'")
  end
end