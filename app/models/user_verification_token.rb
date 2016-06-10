class UserVerificationToken

  class UserVerificationTokenParseError < StandardError; end

  def initialize(user_id, token = nil)
    @user_id = user_id
    @token = token
    @user_searched = false
    @token_generator = UserAuthenticationToken.new(user)
  end

  def self.token(user_id)
    token = new(user_id)
    token.generate
  end

  def self.parse(token)
    user_id = token[24..-1] if token.present? && token.length > 24
    if user_id.nil?
      raise ParseError.new("Malformed user verification token: #{token}; Missing user id")
    end
    UserVerificationToken.new(user_id, token)
  end


  def generate
    @token_generator.generate
  end

  def user
    if @user.nil? && !@user_searched
      begin
        @user = User.find(@user_id)
      rescue
        # keep going, track that we hit the db and got nothing
      end
      @user_searched = true
    end
    @user
  end

  def valid?
    user.present? && @token == generate
  end

end
