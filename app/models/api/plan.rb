module Api

  class Plan < ActiveRecord::Base
    db_magic :connection => :api_rw

    validates :name, presence: true

    has_many :plan_endpoints
    has_many :endpoints, through: :plan_endpoints

    def demographics_included?
      %w(premium professional).include? name
    end

    def subratings_included?
      %w(premium).include? name
    end

    def enterprise?
      name == 'enterprise'
    end
  end

end