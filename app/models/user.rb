class User < ActiveRecord::Base
  self.table_name = 'list_member'

  db_magic :connection => :gs_schooldb

  has_one :user_profile
  has_many :subscriptions, foreign_key: 'member_id'
  has_many :favorite_schools, foreign_key: 'member_id'
  has_many :esp_memberships, foreign_key: 'member_id', :conditions => ['active = 1']

  validates_presence_of :email
  validates :email, uniqueness: { case_sensitive: false }
  before_save :verify_email!, if: "facebook_id != nil"
  before_save :encrypt_plain_text_password
  after_save :create_user_profile, :encrypt_plain_text_password_after_first_save
  validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/, message: 'Please enter a valid email address.'
  validates :plain_text_password, length: { in: 6..14 }, if: :should_validate_password?

  after_initialize :set_defaults

  attr_accessible :email, :password, :facebook_id, :first_name, :last_name, :how
  attr_accessor :updating_password

  SECRET = 23088
  PROVISIONAL_PREFIX = 'provisional:'

  def self.with_email(email)
    where(email: email).first
  end

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
    # TODO: expose this behavior as a different method to users of User class, such as plain_text_password=
    ActiveSupport::Deprecation.silence do
      self[:plain_text_password] = password
    end
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

  def has_subscription?(list)
    subscriptions.any? do |subscription|
      subscription.list == list && (subscription.expires.nil? || Time.parse(subscription.expires.to_s).future?)
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
      UserProfile.create!(member_id: id, screen_name: "user#{id}", private:true, how:self.how, active: true, state:'ca')
    end
  end

  def set_defaults
    self.time_added = Time.now
  end



end
