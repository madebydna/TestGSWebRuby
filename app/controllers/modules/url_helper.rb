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

  def ratings_path_for_lang
    if I18n.locale == :es
      ratings_spanish_path
    else
      ratings_path
    end
  end

  # This function should be used when you need to look up a parameter by its name.
  # To revert, use gs_legacy_url_decode
  def gs_legacy_url_encode(param)
    return nil if param.nil?
    param.downcase.gsub('-', '_').gsub(' ', '-')
  end
  alias :gs_legacy_url_city_encode :gs_legacy_url_encode
  alias :gs_legacy_url_city_district_browse_encode :gs_legacy_url_encode

  # The opposite of gs_legacy_url_encode. Use this to get the name back from a param
  # that was created with the encode method.
  def gs_legacy_url_decode(param)
    return nil if param.nil?
    param.gsub('-', ' ').gsub('_', '-')
  end

  def encode_school_name(param)
    param = param.gsub(' ', '-')
    .gsub('/', '-')
    .gsub('#', '')
    .gsub('`', '')

    # Transliterates UTF-8 characters to ASCII. By default this method will
    # transliterate only Latin strings to an ASCII approximation:
    param = I18n.transliterate(param)

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

  def school_params_hash(school_hash)
    hash = {}
    hash[:state] = gs_legacy_url_encode(school_hash[:state_name]) if school_hash[:state_name].present?
    hash[:city] = gs_legacy_url_encode(school_hash[:city]) if school_hash[:city].present?
    hash[:schoolId] = school_hash[:id ]if school_hash[:id]
    hash[:school_name] = encode_school_name(school_hash[:name]) if school_hash[:name].present?
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

  def state_params(state)
    {
      state: gs_legacy_url_encode(States.state_name state)
    }
  end

  def district_params(state, city, district)
    {
      state: gs_legacy_url_encode(States.state_name state),
      city: gs_legacy_url_encode(city),
      district: gs_legacy_url_encode(district)
    }
  end

  def district_params_from_district(district)
    {
      state: gs_legacy_url_encode(States.state_name district.state),
      city: gs_legacy_url_encode(district.city),
      district: gs_legacy_url_encode(district.name)
    }
  end

  def school_media_image_path(state, img_size, media_hash)
    comm_media_prefix = "library/"
    ENV_GLOBAL['media_server'] + '/' + comm_media_prefix + "school_media/" + state.downcase + "/" + media_hash[0,2] + "/" + media_hash + "-#{img_size}.jpg"
  end

  def catalog_path(path = '')
    "#{ENV_GLOBAL['catalog_server']}/#{path}".gsub('//','/').gsub('//','/').sub(':/', '://')
  end

  # url helper method to help shape the params before sending it to the next level
  # params_hash[:refresh_canonical_link] is used in the populate_canonical_url_for_schools script to refresh the db
  %w(school school_user).each do |helper_name|
    define_method "#{helper_name}_path" do |school, params_hash = {}|
      return add_query_params_to_url(school.canonical_url, true, remove_default_params_options(params_hash.compact)) if use_db_canonical_url?(helper_name, school, params_hash)

      if school.nil?
        params = school_params_hash params_hash
      else
        params = school_params school
        params.merge! params_hash.compact
      end
      super params
    end
    define_method "#{helper_name}_url" do |school, params_hash = {}|
      return add_query_params_to_url(root_url.chop + school.canonical_url, true, remove_default_params_options(params_hash.compact)) if use_db_canonical_url?(helper_name, school, params_hash)

      if school.nil?
        params = school_params_hash params_hash
      else
        params = school_params school
        params.merge! params_hash.compact
      end
      super params
    end
  end

  %w(school_details school_quality school_reviews).each do |helper_name|
    define_method "#{helper_name}_path" do |school, params_hash = {}|
      school_path school, params_hash
    end
    define_method "#{helper_name}_url" do |school, params_hash = {}|
      school_url school, params_hash
    end
  end

  def email_verification_url(user)
    tracking_code = 'eml_join_verify'

    verification_link_params = {}
    post_registration_redirect = Addressable::URI.parse(
      post_registration_confirmation_url
    )
    post_registration_redirect.query_values ||= { redirect: password_url }
    hash, date = EmailVerificationToken.token_and_date(user)
    verification_link_params.merge!(
      id: CGI.escape(hash),
      date: date,
      redirect: post_registration_redirect.to_s,
      s_cid: tracking_code
    )
    verify_email_url(verification_link_params).gsub("admin.greatschools.org", "www.greatschools.org")
  end

  # remove hash/anchor if it exists - write anchor to current url.
  # @param  s [String] a full URL or URL path
  def set_anchor(s, anchor)
    uri = Addressable::URI.parse(s)
    uri.fragment = anchor.present? ? anchor : ''
    uri.to_s
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

  def create_authenticate_token_url(user, redirect, params = {})
    hash, date = EmailVerificationToken.token_and_date(user)
    params = params.reverse_merge({
      id: CGI.escape(hash),
      date: date,
      redirect: redirect
    })
    authenticate_token_url(params)
  end

  def create_reset_password_url(user, params = {})
    params = params.reverse_merge({
      s_cid: 'eml_passwordreset'
    })
    create_authenticate_token_url(user, password_url, params)
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

  # parse a query string, adding repeat parameters into arrays
  # e.g. ?a=b&a=c returns {'a' => ['b','c']}
  def parse_array_query_string(query_string)
    query_s = query_string.gsub( /\[\]\=/ , '=').gsub('%5B%5D=', '=') # %5B%5D is []
    Rack::Utils.parse_query(query_s)
  end
  # Rack::Utils.parse_query does not handle rails style arrays
  # ex. array[]=value1&array[]=value2
  # Rack::Utils.parse_nested_query handles rails style arrays, but not CGI
  # ex. array=value1&array=value2
  # To handle both, the above method will remove [] from string and use parse_query
  # Thus making the resulting hash keys 'key' instead of 'key[]'

  #removes rails convention bracket array parameters from string
  #ex. {names: ['bob', 'bobby']} will now become names=bob&names=bobby instead of names[]=bob&names[]=bobby
  #To prevent unintended behavior, pass in a params hash that has been normalized by the parse_array_query_string method above

  def encode_square_brackets(query_string)
    query_string.gsub('[','%5B').gsub(']','%5D')
  end

  def hash_to_query_string(hash)
    CGI.unescape(hash.to_param).gsub(/\[\]/ , '')
  end

  # Input: hash for a school with id, state, city, name
  # Output: returns a string of the url to the profile
  def school_hash_to_url_for_profile(school_hash)
    normalized_name =  encode_school_name(school_hash['name'])
    city_name = gs_legacy_url_encode(school_hash['city'])
    state_name = gs_legacy_url_encode(States.state_name(school_hash['state']))
    school_id = school_hash['id']
    return nil unless normalized_name && city_name && state_name && school_id
    school_url = "/#{state_name}/#{city_name}/#{school_id}-#{normalized_name}/"
    school_url += "?lang=#{params[:lang]}" if params[:lang]
    school_url
  end

  def zillow_url(state, zipcode, campaign=nil)
    campaign ||= 'gstrackingpagefail'
    tracking_codes = "?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=#{campaign}"
    # test that values needed are populated
    if state.present? && zipcode.present?
      url = "https://www.zillow.com/#{States.abbreviation(state).upcase}-#{zipcode.split("-")[0]}"
    else
      url = 'https://www.zillow.com/'
    end
    "#{url}#{tracking_codes}"
  end

  private

  def use_db_canonical_url?(helper_name, school, params_hash)
    helper_name == 'school' && school.try(:canonical_url) && !params_hash.has_key?(:refresh_canonical_link)
  end

  def remove_default_params_options(params_hash)
    default_options = %i(anchor only_path trailing_slash host protocol user password)
    shallow_copy_of_hash = params_hash.clone
    default_options.each {|option| shallow_copy_of_hash.delete(option)}
    shallow_copy_of_hash
  end

end
