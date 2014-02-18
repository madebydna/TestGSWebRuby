module UrlHelper
  require 'addressable/uri'

  # The key for each URL will be turned into two helper methods that can be used in views
  # e.g.  terms_of_use_path  and  terms_of_use_url
  # The user of those methods can set query params as necessary
  LEGACY_URL_MAP = {
    home: '/index.page',
    our_mission: '/about/aboutUs.page',
    our_people: '/about/senior-management.page',
    jobs: '/jobs/',
    contact_us: '/about/feedback.page',
    advertise: '/about/advertiserOpportunities.page',
    partners: '/about/partnerOpportunities.page',
    media_room: '/about/pressRoom.page',
    widgets_and_tools: '/about/linkToUs.page',
    how_we_rate_schools: '/find-a-school/defining-your-ideal/2423-ratings.gs',
    terms_of_use: '/terms/',
    school_review_guidelines: '/about/guidelines.page',
    privacy: '/privacy/',
    forgot_password: '/community/forgotPassword.page',
    worksheets_and_activities: '/worksheets-activities.topic?content=4313',
    parenting_dilemmas: '/parenting-dilemmas.topic?content=4321',
    learning_difficulties: '/special-education.topic?content=1541',
    health_and_behavior: '/parenting.topic?content=1539',
    find_schools: '/find-schools/',
    the_scoop: '/school/parentReview.page',

    state: '/{state}/',
    city: '/{state}/{city}/',
    choosing_schools: '/{state}/{city}/choosing-schools/',
    education_community: '/{state}/{city}/education-community/',
    enrollment: '/{state}/{city}/enrollment/',
    events: '/{state}/{city}/events/',

    # TODO: these two below should not be specifying the city and stateId inline.
    osp_register: '/official-school-profile/register.page?city={city}&schoolId={school_id}&state={state}',
    osp_form: '/school/QandA/form.page?schoolId={school_id}&state={state}'
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
        if path.match /{#{key}}/
          path = path.gsub /{#{key}}/, value
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
				city: gs_legacy_url_encode(@school.hub_city)
			}
		elsif cookies[:ishubUser] == 'y' && cookies[:hubState].present? && cookies[:hubCity].present?
			{
				state: gs_legacy_url_encode(States.state_name cookies[:hubState]),
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

  %w(school school_details school_quality school_reviews school_review_form).each do |helper_name|
    define_method "#{helper_name}_path" do |school|
      params = school_params school
      if school.preschool?
        send "pre#{helper_name}_path", params
      else
        super params
      end
    end
    define_method "#{helper_name}_url" do |school|
      params = school_params school
      if school.preschool?
        # If we dont add the pk subdomain here, the url's subdomain will default to non-pk subdomain
        # and although the user will get to the right page when they click the link,
        # it will happen via a 301 redirect, which we dont want
        send "pre#{helper_name}_url", (params.merge(subdomain: PreschoolSubdomain.pk_subdomain(request)))
      else
        super params
      end
    end
  end

  # Host will only include port if it is not 80 and not 443
  def base_href
    host = request.host_with_port
    if request.subdomain.present?
      host = host.sub request.subdomain, PreschoolSubdomain.default_subdomain(request)
    end
    "#{request.scheme}://#{host}"
  end

end