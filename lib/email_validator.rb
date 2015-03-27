class EmailValidator

  attr_reader :email

  VALID_FORMAT_REGEX = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  def initialize(email)
    @email = email
  end

  def format_valid?
    !! email.match(VALID_FORMAT_REGEX)
  end
end