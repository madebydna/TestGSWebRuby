class User < ActiveRecord::Base
  self.table_name = 'list_member'

  attr_accessible :password

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable, :omniauthable,
  # :rememberable, :trackable, :validatable, :recoverable
  devise :database_authenticatable, :registerable

  db_magic :connection => :gs_schooldb

  validates_presence_of :email
  validates_presence_of :password

  def encrypted_password
    attributes['password']
  end

  SECRET = 23088
  PROVISIONAL_PREFIX = 'provisional:'

  def auth_token
    Digest::MD5.base64digest("#{SECRET}#{id}") + id.to_s
  end

  def password_matches(password)
    digest = Digest::MD5.new
    digest.update SECRET.to_s
    digest.update password
    digest.update id.to_s
    target_password = digest.base64digest

    prefix_index = encrypted_password.index PROVISIONAL_PREFIX

    user_password =
      if prefix_index
        encrypted_password[(PROVISIONAL_PREFIX.length + prefix_index)..-1]
      else
        encrypted_password
      end

    user_password == target_password
  end

  def provisional?
    # TODO: write implementation
    false
  end

end
