# frozen_string_literal: true

class RatingConfiguration < ActiveRecord::Base
  self.table_name = 'rating_configurations'
  db_magic connection: :gsdata

  def self.max_year(state, rating_type, data_type_id)
    where(state: state, rating_type: rating_type, data_type_id: data_type_id, active: true).maximum('year')
  end

  def self.max_year_two(state, data_type_id)
    where(state: state, data_type_id: data_type_id, active: true).maximum('year')
  end

end