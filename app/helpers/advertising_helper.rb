module AdvertisingHelper

  protected
  def format_ad_setTargeting(value)
    value.to_s.delete(' ').slice(0,10)
  end

end