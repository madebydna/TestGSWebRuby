class Encryption

  SECRET = 23088

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def encrypt_password(password)
    if password.present?
      Digest::MD5.base64digest("#{SECRET}#{password}#{user.id}")
    end
  end

end