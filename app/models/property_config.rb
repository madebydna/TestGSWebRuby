class PropertyConfig < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'property'

  def self.sweepstakes?
    pc_sweepstakes = PropertyConfig.where(quay: 'sweepstakes')
    pc_sweepstakes.present? ? pc_sweepstakes.first.value == 'true' : false
  end

  def self.get_property(quay, fail_return_val = '')
    cache_key = 'PropertyConfig/' + quay
    property = Rails.cache.fetch(cache_key, expires_in: 2.minutes) do
      PropertyConfig.where(quay: quay).order("id DESC").first
    end

    property.present? ? property.value : fail_return_val
  end

  def self.force_review_moderation?
    Rails.cache.fetch('PropertyConfig/force_review_moderation', expires_in: 2.minutes) do
      property = PropertyConfig.where(quay: 'force_review_moderation')
      property.present? ? property.first.value == 'true' : false
    end
  end

  def self.advertising_enabled?
    Rails.cache.fetch('PropertyConfig/advertising_enabled', expires_in: 2.minutes) do
      property = PropertyConfig.where(quay: 'advertisingEnabled')
      property.present? ? property.first.value == 'true' : true
    end
  end

  def self.show_facebook_comments?(state)
    facebook_property = get_property('facebook_comments')
    property_state_on?(facebook_property, state)
  end

  #//////////////////////////////////////////////
  #
  # Compare the comma separated list of states(state_list_str) with the state you wish to compare to(current_state)
  #   returns true is state is part of list or if all is present in list
  #   returns false if state is not found and all is not in list
  #
  #//////////////////////////////////////////////
  def self.property_state_on?(state_list_str, current_state)
    state_arr = state_list_str.split(',') if state_list_str.present?
    if state_arr.present?
      state_arr.select!{ |state| state.upcase == current_state.upcase || state.upcase == 'ALL' }
      state_arr.present?
    else
      false
    end
  end
end