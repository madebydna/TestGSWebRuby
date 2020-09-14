module Api

  class User < ActiveRecord::Base
    self.table_name = 'users'
    db_magic :connection => :api_rw

    has_one :subscription
    has_many :awaiting_approval_subscriptions, -> { awaiting_bizdev_approval }, class_name: "Subscription"

    validates :first_name, :last_name, :organization, :website, :email, :phone, :city, :state, presence: true
    validates :organization_description, :role, :intended_use, presence: true
    validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

    has_one :subscription, class_name: 'Api::Subscription'

    def full_name
      [first_name, last_name].compact.join(' ')
    end

    def locality
      [city, state&.upcase].compact.join(', ')
    end

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