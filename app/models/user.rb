class User < ActiveRecord::Base
  self.table_name = 'list_member'

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable, :omniauthable,
  # :rememberable, :trackable, :validatable, :recoverable
  devise :database_authenticatable, :registerable

  db_magic :connection => :gs_schooldb

  validates_presence_of :email
  validates_presence_of :password

  alias_attribute :encrypted_password, :password

  SECRET = 23088

  def auth_token
    Base64.strict_encode64(Digest::MD5.digest("#{SECRET}#{id}")) + id.to_s
  end

end
