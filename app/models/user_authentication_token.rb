class UserAuthenticationToken
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def generate
    Digest::MD5.base64digest("#{Encryption::SECRET}#{user.id}") + user.id.to_s
  end

  def matches?(other)
    generate == other
  end
end