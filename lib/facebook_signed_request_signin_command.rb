class FacebookSignedRequestSigninCommand
  attr_accessor :app_secret, :signed_request, :email, :params

  def self.new_from_request_params(params)
    params = params.dup
    facebook_signed_request = params.delete('facebook_signed_request')
    email = params.delete('email')
    self.new(facebook_signed_request, email, params)
  end

  def initialize(signed_request, email, params = {})
    self.app_secret = ENV_GLOBAL['facebook_app_secret']
    self.signed_request = signed_request
    self.email = email
    self.params = params
    raise 'Facebook signed request invalid' unless valid_request?
  end

  def valid_request?
    @_valid_request ||= (
    signed_request.nil? ? false : MiniFB.verify_signed_request(app_secret, signed_request)
    )
  end

  def find_or_create_user
    if existing_user
      return existing_user, nil, false
    else
      user, error = create_user
      return user, error, true
    end
  end

  def join_or_signin
    user, error, is_new_user = find_or_create_user
    yield user, error, is_new_user
  end

  def existing_user?
    existing_user != nil
  end

  def existing_user
    return @_existing_user if defined? @_existing_user
    @_existing_user = User.find_by_email(email)
  end

  def user_attributes_from_params
    attributes = {}
    attributes[:facebook_id] = params['facebook_id'] if params['facebook_id']
    attributes[:first_name] = params['first_name'] if params['first_name']
    attributes[:last_name] = params['last_name'] if params['last_name']
    attributes
  end

  def create_user
    user = User.new_facebook_user(user_attributes_from_params)
    user.email = email
    unless user.save
      return nil, user.errors.messages.first[1].first
    end
    return user, nil
  end

end