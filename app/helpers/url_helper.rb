module UrlHelper

  def gs_legacy_url_encode(param)
    param.downcase.gsub('-', '_').gsub(/\s+/, '-')
  end

  def encode_school_name(param)
    param.gsub!(' ', '-')
    param.gsub!('/', '-')
    param.gsub!('#', '')
    param.gsub!('`', '')

    # Replaces non-ASCII characters with an ASCII approximation, or if none exists,
    # a replacement character which defaults to “?”
    param = ActiveSupport::Inflector.transliterate param, ''

    param.gs_capitalize_words!

    param = CGI.escape param

    param.gsub '&..', ''
  end

  def school_params(school)
    {
      state: gs_legacy_url_encode(school.state_name),
      city: gs_legacy_url_encode(school.city),
      schoolId: school.id,
      school_name: encode_school_name(school.name)
    }
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



  # Create a methodname_url method for every methodname_path method in this file.
  # e.g. create city_url and state_url methods which give absolute URLs for those pages
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