module AdvertisingHelper

  protected

  #executed in application controller to set the formatted gon hash
  def set_ad_targeting_gon_hash!
    ad_targeting_gon_hash
  end

  #assign formatted gon hash to gon.ad_set_targeting, but modify the hash via the memoized instance variable reference
  def ad_targeting_gon_hash
    @ad_targeting_gon_hash ||= (gon.ad_set_targeting = AdvertisingFormatterHelper.formatted_gon_hash)
  end

  private

  module AdvertisingFormatterHelper
    module_function
    def formatted_gon_hash
      HashWithSetterCallback.new { |key, value| [key, format_ad_setTargeting(value)] }
    end

    def format_ad_setTargeting(value)
      value.to_s.delete(' ').slice(0,10)
    end
  end
end