module Password
  def self.included(base)
    base.class_eval do
      # Add a db attribute to the model
      attr_accessible :password

      # Add two getter/setter methods
      attr_accessor :updating_password, :plain_text_password

      # Before the object is saved, encrypt the plain text password
      before_save :encrypt_plain_text_password

      # After the object is saved for the first time, encrypt the password
      after_create :encrypt_plain_text_password_after_first_save

      # Add model-level validation
      validates :plain_text_password, length: { in: 6..14 }, if: :should_validate_password?
    end
  end

  PROVISIONAL_PREFIX = 'provisional:'

  # Returns the plain text password in the case where it has been set and not encrypted yet
  def password
    plain_text_password
  end

  # set a plain text password. Does not modify the underlying database attribute, just sets
  # a @plain_text_password instance variable
  def password=(password)
    # TODO: expose this behavior as a different method to users of User class, such as plain_text_password=
    ActiveSupport::Deprecation.silence do
      self.plain_text_password = password
    end
  end

  # Returns true if the user has set a password
  def has_password?
    encrypted_password.present?
  end

  def password_is_provisional?
    encrypted_password.present? && read_attribute(:password).include?(PROVISIONAL_PREFIX)
  end

  # Check if the given plain text password, after being encrypted, matches the encrypted
  # password stored in the data attribute
  def password_is?(password)
    encrypted_password.present? && encrypted_password == encrypt_password(password)
  end

  # Encrypts a password. Does not modify user, but relies on having the user's ID
  def encrypt_password(password)
    Encryption.new(self).encrypt_password(password)
  end

  def encrypted_password=(encrypted_password)
    # TODO: expose this behavior as a method password= using the attr_writer helper.
    # force users of User class to set plain text password using a different method name, such as plain_text_password=
    ActiveSupport::Deprecation.silence do
      write_attribute(:password, encrypted_password)
    end
  end

  # returns the password that is stored as a DB attribute
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

  # Determines if we should run the ActiveRecord password validation we set up
  # Only do this when a new plain text password is set (when user sets a pw for the first time, or updates it)
  # Running this validation on every save wouldn't work, since once we encrypt a plain text password, the plain
  # text password is gone and cannot be validated in the future
  def should_validate_password?
    updating_password || new_record?
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

end