class User < ActiveRecord::Base
  self.table_name = 'list_member'

  db_magic :connection => :gs_schooldb

  has_one :user_profile

  validates_presence_of :email
  validates :email, uniqueness: { case_sensitive: false }
  before_save :encrypt_plain_text_password
  after_save :create_user_profile, :encrypt_plain_text_password_after_first_save
  validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/, message: 'Please enter a valid email address.'
  validates :plain_text_password, length: { in: 6..14 }, if: :should_validate_password?

  after_initialize :set_defaults

  attr_accessible :email, :password, :facebook_id, :first_name, :last_name, :how
  attr_accessor :updating_password

  SECRET = 23088
  PROVISIONAL_PREFIX = 'provisional:'

  scope :with_email, lambda { |email| where(email: email).first }

  def school_reviews
    SchoolRating.belonging_to(self).order('posted desc')
  end

  def published_reviews
    school_reviews.published
  end

  def provisional_reviews
    school_reviews.provisional
  end

  def self.email_taken?(email)
    User.where(email:email).any?
  end

  def provisional?
    encrypted_password.present? && encrypted_password.index(PROVISIONAL_PREFIX) || !email_verified?
  end

  def self.validate_email_verification_token(token, time_string)
    begin
      token = EmailVerificationToken.parse token, time_string
    rescue
      return false
    end
    if token.valid?
      user = token.user
      user.email_verified = true
      return user
    else
      return false
    end
  end

  def email_verification_token(time = nil)
    token = EmailVerificationToken.new(user: self, time: time)
    [token.generate, token.time_as_string]
  end

  def password=(password)
    write_attribute :plain_text_password, password
  end
  def password
    read_attribute(:plain_text_password)
  end

  def encrypt_plain_text_password_after_first_save
    # TODO: put this elsewhere

    if password.present? && encrypted_password.blank?
      encrypt_plain_text_password
      save!
    end
  end

  def encrypt_plain_text_password
    if password.present? && id.present?
      encrypted_pw = encrypt_password(password)
      if email_verified?
        self.encrypted_password = encrypted_pw
      else
        self.encrypted_password = password + PROVISIONAL_PREFIX + encrypted_pw
      end
    end
  end

  def encrypt_password(password)
    if password.present?
      Digest::MD5.base64digest SECRET.to_s + password + id.to_s
    end
  end

  def password_is?(password)
    encrypted_password.present? && encrypted_password == encrypt_password(password)
  end

  def auth_token
    Digest::MD5.base64digest("#{SECRET}#{id}") + id.to_s
  end

  def verify!
    # legacy java code puts plaintext password and a 'provisional:' string in the password field until account
    # is verified. After that, the plaintext password and prefix are removed, leaving just the hashed password
    # looking at the implementation of encrypted_password will explain
    self.encrypted_password = encrypted_password

    verify_email!
  end

  def verify_email!
    self.email_verified = true
  end

  def publish_reviews!
    reviews_to_upgrade = provisional_reviews
    # make provisional reviews 'not provisional', i.e. deleted, published, or held
    reviews_to_upgrade.each do |review|
      upgraded_review ||= review
      review.remove_provisional_status!
      review.save!
    end

    # return reviews that are published now
    reviews_to_upgrade.select { |review| review.published? }
  end

  def has_facebook_account?
    facebook_id.present?
  end

  private

  def encrypted_password=(encrypted_password)
    write_attribute(:password, encrypted_password)
  end

  def encrypted_password
    pw = read_attribute(:password)
    prefix_index = nil

    prefix_index = pw.rindex PROVISIONAL_PREFIX if pw.present?

    if prefix_index
      pw[(PROVISIONAL_PREFIX.length + prefix_index)..-1]
    else
      pw
    end
  end

  def should_validate_password?
    updating_password || new_record?
  end

  def self.generate_password
    SecureRandom.urlsafe_base64 8
  end

  def create_user_profile
    profile = UserProfile.where(member_id: id).first
    if profile.nil?
      UserProfile.create!(member_id: id, screen_name: "user#{id}", private:true, how:self.how, active: true, state:'ca')
    end
  end

  def set_defaults
    self.time_added = Time.now
  end

end
