class EmailVerificationToken

  class EmailVerificationTokenParseError < StandardError; end

  EMAIL_TOKEN_EXPIRATION = 5.days

  def initialize(options = {})
    if options[:user]
      @user = options[:user]
      @user_id = @user.id
    else
      @user_id = options[:user_id]
    end

    @token = options[:token]
    @time = options[:time] || Time.now
    @user_searched = false

    if @user.nil? && @user_id.nil?
      raise 'Must initialize EmailVerificationToken with a user or user ID'
    end
  end

  def self.parse(token, time_string)
    user_id = token[24..-1] if token.present? && token.length > 24

    if user_id.nil?
      raise EmailVerificationTokenParseError.new("Malformed email verification token: #{token}")
    end

    EmailVerificationToken.new(user_id: user_id, time:time_from_string(time_string), token: token)
  end

  def self.time_from_string(time_string)
    Time.at(time_string.to_i / 1000)
  end

  def time_as_string
    (@time.to_i * 1000).to_s
  end

  def generate
    # Array#pack generates a byte sequence
    # the N argument will make it use 32-bit unsigned, network (big-endian) byte order
    # matches what java currently does in GSWeb
    email_id_hash = Digest::MD5.base64digest(user.email + Array(user.id).pack('N'))

    digest = Digest::MD5.base64digest(email_id_hash + time_as_string)
    digest + user.id.to_s
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

  def expired?
    EMAIL_TOKEN_EXPIRATION.ago > @time
  end

  def valid?
    !expired? && user.present? && @token == generate
  end

end