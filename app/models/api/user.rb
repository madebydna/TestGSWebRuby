module Api

  class User < ActiveRecord::Base
    self.table_name = 'users'
    db_magic :connection => :api_rw

    validates :first_name, :last_name, :organization, :website, :email, :phone, :city, :state,  presence: true
    validates :organization_description, :role, :intended_use,  presence: true
    validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
    validates_confirmation_of :email, message: 'does not match email.'

  end

end