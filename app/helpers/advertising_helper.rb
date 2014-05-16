module AdvertisingHelper

  [:desktop, :mobile].each do |view|
    method_name = "render_#{view}_ad_slot"

    define_method(method_name) do |slot|
      render('layouts/ad_layer', 
        page: @page_config.name.to_sym,
        slot: slot,
        view: view
      )
    end
  end

end