# frozen_string_literal: true

class BreakdownTag < ActiveRecord::Base
  self.table_name = 'breakdown_tags'
  db_magic connection: :omni

  belongs_to :breakdown

end
