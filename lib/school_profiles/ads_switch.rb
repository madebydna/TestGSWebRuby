module AdsSwitch
  def self.disable_ads_for_current_request
    RequestStore.store['show_ads'] = false
  end

  def self.ads_enabled_for_current_request?
    !self.ads_disabled_for_current_request?
  end

  def self.ads_disabled_for_current_request?
    RequestStore.store['show_ads'] == false || !PropertyConfig.advertising_enabled?
  end
end
