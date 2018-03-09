# frozen_string_literal: true

class Academic < ActiveRecord::Base
  self.table_name = 'academics'
  db_magic connection: :gsdata
  self.inheritance_column = nil

  has_many :data_values_to_academics, inverse_of: :academic
  has_many :academic_tags
  has_many :data_values, through: :data_values_to_academics, inverse_of: :academics
end
