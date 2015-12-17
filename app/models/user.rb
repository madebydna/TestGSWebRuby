class User < ActiveRecord::Base
  # reviews
  include UserReviewConcerns
  include UserEmailConcerns
  include UserProfileAssociation
  include UserEspMemberships
  include Subscriptions
  include FavoriteSchoolsAssociation
  include StudentGradeLevelsAssociation
  include RolesAssociation

  # Include Password
  # Causes additional before_save / after_create hooks to be executed !
  include Password

  self.table_name = 'list_member'
  db_magic :connection => :gs_schooldb

  has_many :saved_searches, foreign_key: 'member_id'
  has_many :review_votes, foreign_key: 'member_id'

  validates_presence_of :email
  validates :email, uniqueness: { case_sensitive: false }
  before_save :verify_email!, if: "facebook_id != nil"
  # creating an encrypted pw for user requires their user ID. So pw must be encrypted after first time user is saved
  after_create :create_user_profile
  validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/, message: 'Please enter a valid email address.'

  after_initialize :set_defaults

  attr_accessible :email, :facebook_id, :first_name, :last_name, :how,:welcome_message_status

  scope :verified, -> { where(email_verified: true) }

  def self.new_facebook_user(attributes)
    user = self.new
    user.assign_attributes(attributes.reverse_merge(how: 'facebook', password: Password.generate_password))
    user
  end

  def self.with_email(email)
    where(email: email).first
  end

  def self.email_taken?(email)
    User.where(email:email).any?
  end

  def provisional?
    password_is_provisional? || !email_verified?
  end

  def email_verification_token(time = nil)
    token = EmailVerificationToken.new(user: self, time: time)
    [token.generate, token.time_as_string]
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

  def has_facebook_account?
    facebook_id.present?
  end

  def flagged_review?(review)
    self.reviews_user_flagged.map(&:id).include? review.id
  end

  protected

  def set_defaults
    now = Time.now
    self.time_added ||= now
    self.updated ||= now
  end

  def log_user_exception(e)
    Rails.logger.warn("Error: #{e.message} for user ID #{id}, email: #{email}. Stacktrace:")
    Rails.backtrace_cleaner.clean(e.backtrace).each { |frame| Rails.logger.warn(frame) }
  end

end
