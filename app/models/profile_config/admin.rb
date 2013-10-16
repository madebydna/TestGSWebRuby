class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  db_magic :connection => :profile_config

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  rails_admin do
    visible false
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
end
