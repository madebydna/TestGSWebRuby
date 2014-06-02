module AdvertisingHelper

  protected

  [:desktop, :mobile].each do |view|
    method_name = "render_#{view}_ad_slot"

    define_method(method_name) do |slot|
      render('layouts/ad_layer', 
        page: @page_config.name.to_sym,
        slot: slot,
        view: view
      )
    end
    send :protected, method_name
  end

  def format_ad_setTargeting(value)
    value.to_s.delete(' ').slice(0,10)
  end

end