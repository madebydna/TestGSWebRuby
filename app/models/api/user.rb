module Api

  class User < ActiveRecord::Base
    self.table_name = 'users'
    db_magic :connection => :api_rw

    validates :first_name, :last_name, :organization, :website, :email, :phone, :city, :state,  presence: true
    validates :organization_description, :role, :intended_use,  presence: true
    validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
    validates_confirmation_of :email, message: 'does not match email.'

    INDUSTRIES = [
      'Real Estate',
      'Journalism & Media',
      'Government & Policy',
      'Education',
      'Finance',
      'Other'
    ]

    ROLES = [
      'Management',
      'Data Scientist',
      'Business Development',
      'Academic',
      'Other'
    ]

    INTENDED_USE = [
      'Public website display',
      'Software as a service',
      'Marketing & outreach',
      'Commercial research & analysis',
      'Academic research',
      'Personal school search',
      'Other'
    ]

  end

end