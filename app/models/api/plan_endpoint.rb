module Api

  class PlanEndpoint < ActiveRecord::Base
    db_magic :connection => :api_rw

    belongs_to :plan
    belongs_to :endpoint
  end

end