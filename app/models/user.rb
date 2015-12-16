class User < ActiveRecord::Base
  # reviews
  include UserReviewConcerns
  include UserEmailConcerns
  include UserProfileAssociation

  # Include Password
  # Causes additional before_save / after_create hooks to be executed !
  include Password

  self.table_name = 'list_member'
  db_magic :connection => :gs_schooldb

  has_many :subscriptions, foreign_key: 'member_id'
  has_many :saved_searches, foreign_key: 'member_id'
  has_many :favorite_schools, foreign_key: 'member_id'
  has_many :esp_memberships, foreign_key: 'member_id'
  has_many :member_roles, foreign_key: 'member_id'
  has_many :roles, through: :member_roles #Need to use :through in order to use MemberRole model, to specify gs_schooldb
  has_many :student_grade_levels, foreign_key: 'member_id'
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
    user.assign_attributes(attributes.reverse_merge(how: 'facebook', password: generate_password))
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

  def auth_token
    Encryption.new(self).auth_token
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

  def add_subscription!(*args)
    subscription = new_subscription *args
    subscription.save!
  end

  def safely_add_subscription!(list, school = nil)
    unless has_subscription?(list, school)
      subscription = new_subscription(list, school)
      subscription.save!
    end
  end

  def new_subscription(list, school = nil)
    now = Time.now

    subscription_product = Subscription.subscription_product list

    raise "Subscription #{list} not valid" if subscription_product.nil?

    state = school.present? ? school.state : 'CA'
    school_id = school.present? ? school.id : 0
    expires = subscription_product.duration.present? ? now + subscription_product.duration : nil

    subscriptions.build(
      list: subscription_product.name,
      state: state,
      school_id: school_id,
      updated: now.to_s,
      expires: expires
    )
  end

  def add_favorite_school!(school)
    favorite_school = FavoriteSchool.build_for_school school
    favorite_schools << favorite_school
    favorite_school.save!
  end

  def has_subscription?(list, school = nil)
    school_id = school.try(:id) || 0
    school_state = school.try(:state) || 'CA'
    if list == 'greatnews'
      subscriptions.any? do |subscription|
        subscription.list == list
      end
    else
      subscriptions.any? do |subscription |
        subscription.list == list && subscription.school_id == school_id && subscription.state == school_state && (subscription.expires.nil? || Time.parse(subscription.expires.to_s).future?)
      end
    end
  end

  def has_signedup?(list)
    subscriptions.any? do |subscription|
      subscription.list == list
    end
  end
  def subscription_id(list)
    subscriptions.any? do |subscription|
       if subscription.list == list
          return subscription.id
       end
    end
  end

  def favorited_school?(school)
    favorite_schools.any? { |favorite| favorite.school_id == school.id && favorite.state == school.state }
  end
  alias_method :favored_school?, :favorited_school?

  def provisional_or_approved_osp_user?(school = nil)
    memberships = self.esp_memberships
    memberships = memberships.for_school(school) if school
    memberships.any? { |membership| membership.approved? || membership.provisional? }
  end

  def esp_membership_for_school(school = nil) #always returns membership if user is a superuser
    return esp_memberships.first if is_esp_superuser?
    school.present? ? esp_memberships.for_school(school).first : nil
  end

  def is_esp_superuser?
    has_role?(Role.esp_superuser)
  end

  def is_active_esp_member?
    esp_memberships.approved_or_provisional.active.present? || is_esp_superuser?
  end

  def is_esp_demigod?
    if esp_memberships.count > 1
      true
    else
      false
    end
  end

  def has_role?(role)
    member_roles.present? && member_roles.any? { |member_role| member_role.role_id == role.id }
  end

  def flagged_review?(review)
    self.reviews_user_flagged.map(&:id).include? review.id
  end

  def add_user_grade_level(grade)
    StudentGradeLevel.find_or_create_by(member_id: id, grade: grade)
  end

  def delete_user_grade_level(grade)
    grade = StudentGradeLevel.find_by(member_id: id, grade: grade)
    grade.delete if grade.present?

  end

  protected

  def self.generate_password
    SecureRandom.urlsafe_base64 8
  end

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
