module Api

  class Plan < ActiveRecord::Base
    self.table_name = 'plans'
    db_magic :connection => :api_rw

    validates :name, presence: true

  end

end