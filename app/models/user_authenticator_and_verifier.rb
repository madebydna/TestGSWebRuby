class UserAuthenticatorAndVerifier

  def initialize(token, time)
    @token = token
    @time = time
    @already_verified = false
  end

  def user
    parse_email_verification_token.user
  end

  def parse_email_verification_token
    @_parse_email_verification_token ||= (
    EmailVerificationToken.parse @token, @time
    )
  end

  def already_verified?
    @already_verified
  end

  def token_valid?
    begin
      token = parse_email_verification_token
      return !(token.expired? || token.user.nil?)
    rescue => e
      # GS.logger.error :misc, nil, {message: e}
      return false
    end
  end

  def authenticated?
    return token_valid? && user.valid?
  end

  def verify_and_publish_reviews!
    @already_verified = user.email_verified?
    user.verify!
    user.save
    user.publish_reviews!
  end
end