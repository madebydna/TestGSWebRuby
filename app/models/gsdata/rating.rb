# frozen_string_literal: true

require 'ruby-prof'

class Rating < ActiveRecord::Base
  self.table_name = 'ratings'

  db_magic connection: :omni

end
