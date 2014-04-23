module UrlHelper
  require 'addressable/uri'
  extend ActiveSupport::Concern

  protected

  included do |base|
    # class methods go in this included{} block

    # Make this modules methods into helper methods view can access
    if base < ActionController::Base
      (UrlHelper.instance_methods - UrlHelper.ancestors).each do |m| 
        base.helper_method m
      end
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
    define_method "#{helper_name}_path" do |school, params_hash = {}|
      params = school_params school
      params.merge! params_hash

      if school.preschool?
        send "pre#{helper_name}_path", params
      else
        super params
      end
    end
    define_method "#{helper_name}_url" do |school, params_hash = {}|
      params = school_params school
      params.merge! params_hash
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

  #
  # Adds a hash of query params to a given path or URL.
  # @param  s [String] a full URL or URL path
  # @param  overwrite [Boolean] if true, overwrites existing params
  #                             otherwise, merges params into an array
  # @param  new_params [Hash] Params to insert
  #
  # @return [String] A new string that includes the given query params
  def add_query_params_to_url(s, overwrite, new_params = {})
    new_params.stringify_keys!
    uri = Addressable::URI.parse(s)

    if new_params.present?
      # Rack::Utils knows how to correctly parse URLs with multiple params
      # with same name
      existing_params = Rack::Utils.parse_nested_query(uri.query)
      new_params.each_pair do |name, param|

        # If asked to overwrite, just overwrite the existing_params key
        # otherwise, create a new Array (if value is not already an array)
        # and append the new param
        if existing_params.has_key?(name) && ! overwrite
          existing_params[name] = Array(existing_params [name]) << param
        else
          existing_params[name] = param.to_s
        end
      end
      string = Rack::Utils.build_nested_query(existing_params )
      uri.query = string
    end

    uri.to_s
  end

  #
  # Removes the given query parameters from a path or URL
  # @param  s [String] a full URL or URL path
  # @param  new_params [Array] Params to remove
  # @param  value = nil [String] If given, must match query param value for
  #                               query param to be removed
  #
  # @return [String] A new path or URL with params removed
  def remove_query_params_from_url(s, new_params, value = nil)
    uri = Addressable::URI.parse(s)

    if new_params.present?
      # Rack::Utils knows how to correctly parse URLs with multiple params
      # with same name
      existing_params = Rack::Utils.parse_nested_query(uri.query)
      new_params.each do |name|
        name = name.to_s
        if value.present?
          existing_value = existing_params[name]
          if existing_value.is_a? Array
            existing_value.delete value
          else
            existing_params.delete name if existing_value == value
          end
        else
          existing_params.delete name
        end
      end
      string = Rack::Utils.build_nested_query(existing_params)
      uri.query = string.presence
    end

    uri.to_s
  end

  # checks for http or https if they don't exist prepend http://
  def prepend_http ( url )
    return_url = url
    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      return_url = "http://#{url}"
    end
    return_url
  end

end