# frozen_string_literal: true

module StateCachedStateAttributeMethods
  def state_attributes
    @_state_attributes ||= cache_data.fetch('state_attributes', {})
  end

  def state_attribute(key_name)
    begin
      state_attributes.fetch(key_name)
    rescue => e 
      GSLogger.error(:misc, nil, message: "#{e}", vars: {key_name: key_name, state: state})
      nil
    end
  end
end
