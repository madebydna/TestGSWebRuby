module UrlHelper
  require 'addressable/uri'

  # The key for each URL will be turned into two helper methods that can be used in views
  # e.g.  terms_of_use_path  and  terms_of_use_url
  # The user of those methods can set query params as necessary
  LEGACY_URL_MAP = {
    terms_of_use: '/terms/',
    school_review_guidelines: '/about/guidelines.page',
    state: '/:state/',
    city: '/:state/:city/',
    choosing_schools: '/:state/:city/choosing-schools/',
    education_community: '/:state/:city/education-community/',
    enrollment: '/:state/:city/enrollment/',
    events: '/:state/:city/events/'
  }

  LEGACY_URL_MAP.each do |name, pattern|
    define_method "#{name.to_s}_url" do |params = {}, options = {}|
      path = self.send "#{name.to_s}_path", params, options

      options = options.reverse_merge(controller.default_url_options)

			# Remain true to whats written in the LEGACY_URL_MAP
      options[:trailing_slash] = false
      ActionDispatch::Http::URL.url_for(options.merge({ path: path }))
    end

    define_method "#{name.to_s}_path" do |params = {}, options = {}|
			path = pattern.clone

      options = options.reverse_merge(controller.default_url_options)

			# Perform replacements on the path pattern
      params.each do |key, value|
        if path.match /:#{key}/
          path = path.gsub /:#{key}/, value
          params.delete key
        end
			end

			Rails.logger.error "Error in url_helper: configured path: #{path} did not have all variables replaced by params: " \
				+ "#{params.to_json}" if path.include? ':'

      # Remain true to whats written in the LEGACY_URL_MAP
      options[:trailing_slash] = false

      options[:path] = path
      options[:only_path] = true

			# Send any params that were left over
      options[:params] = params

      ActionDispatch::Http::URL.url_for(options)
    end
  end

  def gs_legacy_url_encode(param)
    param.downcase.gsub('-', '_').gsub(' ', '-')
  end

  def encode_school_name(param)
    param = param.gsub(' ', '-')
      .gsub('/', '-')
      .gsub('#', '')
      .gsub('`', '')

    # Replaces non-ASCII characters with an ASCII approximation, or if none exists,
    # a replacement character which defaults to “?”
    param = ActiveSupport::Inflector.transliterate param, ''

    param.gs_capitalize_words!

    param = CGI.escape param

    param.gsub /%../, ''
  end

  def school_params(school)
    {
      state: gs_legacy_url_encode(school.state_name),
      city: gs_legacy_url_encode(school.city),
      schoolId: school.id,
      school_name: encode_school_name(school.name)
    }
	end

	def hub_params
		if @school.present?
			{
				state: gs_legacy_url_encode(@school.state_name),
				city: gs_legacy_url_encode(@school.city)
			}
		elsif cookies[:ishubUser] == 'y' && cookies[:hubState].present? && cookies[:hubCity].present?
			{
				state: gs_legacy_url_encode(cookies[:hubState]),
				city: gs_legacy_url_encode(cookies[:hubCity])
			}
		else
			{}
		end
	end

	def city_params(state, city)
		{
			state: gs_legacy_url_encode(States.state_name state),
			city: gs_legacy_url_encode(city)
		}
	end

end