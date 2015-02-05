class User < ActiveRecord::Base
  self.table_name = 'list_member'

  db_magic :connection => :gs_schooldb

  has_one :user_profile, foreign_key: 'member_id'
  has_many :subscriptions, foreign_key: 'member_id'
  has_many :saved_searches, foreign_key: 'member_id'
  has_many :favorite_schools, foreign_key: 'member_id'
  has_many :esp_memberships, foreign_key: 'member_id'
  has_many :reported_reviews, -> { where('reported_entity_type = "schoolReview" and active = 1') }, class_name: 'ReportedEntity', foreign_key: 'reporter_id'
  has_many :member_roles, foreign_key: 'member_id'
  has_many :roles, through: :member_roles #Need to use :through in order to use MemberRole model, to specify gs_schooldb
  has_many :student_grade_levels, foreign_key: 'member_id'
  validates_presence_of :email
  validates :email, uniqueness: { case_sensitive: false }
  before_save :verify_email!, if: "facebook_id != nil"
  before_save :encrypt_plain_text_password
  # creating an encrypted pw for user requires their user ID. So pw must be encrypted after first time user is saved
  after_create :create_user_profile, :encrypt_plain_text_password_after_first_save
  validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/, message: 'Please enter a valid email address.'
  validates :plain_text_password, length: { in: 6..14 }, if: :should_validate_password?

  after_initialize :set_defaults

  attr_accessible :email, :password, :facebook_id, :first_name, :last_name, :how
  attr_accessor :updating_password, :plain_text_password

  SECRET = 23088
  PROVISIONAL_PREFIX = 'provisional:'

  def self.with_email(email)
    where(email: email).first
  end

  def school_reviews
    SchoolRating.belonging_to(self)
  end

  def reviews_for_school(args)
    if args[:school]
      school_id = args[:school].id
      state = args[:school].state
    elsif args[:state] && args[:school_id]
      school_id = args[:school_id]
      state = args[:state]
    else
      raise(ArgumentError, "Must provide :school or :state and :school_id")
    end

    SchoolRating.where(
      member_id: self.id,
      state: state,
      school_id: school_id
    )
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
    # TODO: expose this behavior as a different method to users of User class, such as plain_text_password=
    ActiveSupport::Deprecation.silence do
      self.plain_text_password = password
    end
  end
  def password
    plain_text_password
  end

  def encrypt_plain_text_password_after_first_save
    # TODO: put this elsewhere

    if password.present? && encrypted_password.blank?
      begin
        encrypt_plain_text_password
        save!
      rescue => e
        log_user_exception(e)
        raise e
      end
    end
  end

  def has_password?
    encrypted_password.present?
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
      review.remove_provisional_status!
      review.save!
    end

    # return reviews that are published now
    reviews_to_upgrade.select { |review| review.published? }
  end

  def has_facebook_account?
    facebook_id.present?
  end

  def add_subscription!(*args)
    subscription = new_subscription *args
    subscription.save!
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
    if list == 'greatnews'
      subscriptions.any? do |subscription|
        subscription.list == list
      end
    else
      subscriptions.any? do |subscription|
        subscription.list == list && subscription.school_id == school.id && subscription.state == school.state && (subscription.expires.nil? || Time.parse(subscription.expires.to_s).future?)
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

  def is_esp_superuser?
    has_role?(Role.esp_superuser)
  end

  def has_role?(role)
    member_roles.present? && member_roles.any? { |member_role| member_role.role_id == role.id }
  end

  def reported_review?(review)
    self.reported_reviews.map(&:reported_entity_id).include? review.id
  end

  def is_profile_active?
    user_profile && user_profile.active?
  end

  def add_user_grade_level(grade)
    StudentGradeLevel.find_or_create_by(member_id: id, grade: grade)
  end

  def delete_user_grade_level(grade)
    grade = StudentGradeLevel.find_by(member_id: id, grade: grade)
    grade.delete if grade.present?

  end

  private

  def encrypted_password=(encrypted_password)
    # TODO: expose this behavior as a method password= using the attr_writer helper.
    # force users of User class to set plain text password using a different method name, such as plain_text_password=
    ActiveSupport::Deprecation.silence do
      write_attribute(:password, encrypted_password)
    end
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
      begin
        UserProfile.create!(member_id: id, screen_name: "user#{id}", private:true, how:self.how, active: true, state:'ca')
      rescue => e
        log_user_exception(e)
        raise e
      end
    end
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
