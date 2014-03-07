module UrlHelper
  require 'addressable/uri'
  extend ActiveSupport::Concern

  protected

  # Make this modules methods into helper methods view can access
  def self.included obj
    return unless obj < ActionController::Base
    (instance_methods - ancestors).each { |m| obj.helper_method m }
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
    hash = {}
    hash[:state] = gs_legacy_url_encode(school.state_name) if school.state_name.present?
    hash[:city] = gs_legacy_url_encode(school.city) if school.city.present?
    hash[:schoolId] = school.id if school.id
    hash[:school_name] = encode_school_name(school.name) if school.name.present?
    return hash
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