module UrlHelper

  def gs_legacy_url_encode(param)
    param.downcase.gsub('-', '_').gsub(/\s+/, '-')
  end

  def state_path(options)
    state = options[:state] || ''
    state_name = States.state_name(state)
    state_name = gs_legacy_url_encode(state_name)

    "/#{state_name}"
  end

  def city_path(options)
    city = options[:city] || ''
    state = options[:state] || ''
    if state.downcase == 'ny' && city.downcase == 'new york'
      city = 'new york city'
    end

    city = gs_legacy_url_encode(city)

    "#{state_path(options)}/#{city}"
  end

  self.instance_methods.grep(/_path$/).each do |method|
    define_method "#{method[0..-6]}_url" do |options, params = {}|
      options = (options || {}).reverse_merge!(controller.default_url_options)

      path = send method, options

      ActionDispatch::Http::URL.url_for(options.merge!({
        :path => path,
        :params => params,
      }))
    end
  end

end