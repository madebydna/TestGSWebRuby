module AdvertisingConcerns

  protected

  def show_ads?
    @show_ads
  end

  def advertising_env
    ENV_GLOBAL['advertising_env']
  end

  def set_global_ad_targeting_through_gon
    set_ad_targeting_gon_hash!

    if ab_version == 'a'
      ad_targeting_gon_hash['Responsive_Group'] = 'Control'
    elsif ab_version == 'b'
      ad_targeting_gon_hash['Responsive_Group'] = 'Test'
    end

    @advertising_enabled = advertising_enabled?
    gon.advertising_enabled = @advertising_enabled

    if @advertising_enabled
      ad_targeting_gon_hash['env']         = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    end
  end

  def advertising_enabled?
    advertising_enabled = true
    # equivalent to saying disable advertising if property is not nil and false
    unless ENV_GLOBAL['advertising_enabled'].nil? || ENV_GLOBAL['advertising_enabled'] == true
      advertising_enabled = false
    end
    if advertising_enabled # if env disables ads, don't bother checking property table
      advertising_enabled = PropertyConfig.advertising_enabled?
    end
    return advertising_enabled
  end

  protected

  def set_ad_targeting_props
    return unless advertising_enabled?

    hash = {}
    hash[:env] = advertising_env
    hash[:compfilter] = rand(1..4).to_s

    page_specific_props = 
      ad_targeting_props.each_with_object({}) do |(key, value), h|
        h[key] = AdvertisingFormatterHelper.format_ad_setTargeting(value)
      end

    gon.ad_set_targeting = hash.merge(page_specific_props)
  end

  # Should be overridden in controller
  def ad_targeting_props
    Rails.logger.warn("\e[31m#ad_targeting_props not implemented in #{self.class.name}\e[0m")
    {}
  end

  # deprecated
  #executed in application controller to set the formatted gon hash
  def set_ad_targeting_gon_hash!
    ad_targeting_gon_hash
  end

  # deprecated
  #assign formatted gon hash to gon.ad_set_targeting, but modify the hash via the memoized instance variable reference
  def ad_targeting_gon_hash
    @ad_targeting_gon_hash ||= (gon.ad_set_targeting = AdvertisingFormatterHelper.formatted_gon_hash)
  end

  private

  module AdvertisingFormatterHelper
    module_function
    def unformatted_keys
      %w(address city_long)
    end

    def formatted_gon_hash
      HashWithSetterCallback.new do |key, value|
        # untruncated format if key is found from array of untruncated keys
        if unformatted_keys.include?(key)
          [key, value]
        else
          [key, format_ad_setTargeting(value)]
        end
      end
    end

    def format_ad_setTargeting(value)
      if value.is_a? Array
        value.map { |v| v.to_s.slice(0,10) }.join(',')
      else
        value.to_s.delete(' ').slice(0,10)
      end
    end
  end
end
