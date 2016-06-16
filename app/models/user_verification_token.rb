class UserVerificationToken

  TOKEN_LENGTH = 24

  class UserVerificationTokenParseError < StandardError; end

  def initialize(user_id, token = nil)
    @user_id = user_id
    @token = token
    @token_generator = UserAuthenticationToken.new(user)
  end

  def self.token(user_id)
    token = new(user_id)
    token.generate
  end

  def self.parse(token)
    user_id = get_user_id(token)
    new(user_id, token)
  end

  def self.get_user_id(token)
    user_id = token[TOKEN_LENGTH..-1] if token.present? && token.length > TOKEN_LENGTH
    if user_id.blank?
      raise UserVerificationTokenParseError.new("Malformed user verification token: #{token}; Missing user id")
    end
    user_id
  end

  def generate
    if user.blank?
      raise 'Must initialize UserAuthenticationToken with a user'
    end
    @token_generator.generate
  end

  def user
    return @_user if defined?(@_user)
    @_user = (
      @user = User.find_by_id(@user_id)
    )
  end

  def valid?
    user.present? && @token == generate
  end

end
