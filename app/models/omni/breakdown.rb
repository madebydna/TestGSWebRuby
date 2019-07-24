# frozen_string_literal: true

class Breakdown < ActiveRecord::Base
  self.table_name = 'breakdowns'
  db_magic connection: :omni

  has_many :breakdown_tags

end
