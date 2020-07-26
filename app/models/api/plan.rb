module Api

  class Plan < ActiveRecord::Base
    db_magic :connection => :api_rw

    validates :name, presence: true

    has_many :plan_endpoints
    has_many :endpoints, through: :plan_endpoints
  end

end