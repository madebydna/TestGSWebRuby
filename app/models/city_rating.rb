class CityRating < ActiveRecord::Base
  include StateSharding

  self.table_name = 'city_rating_2'

  scope :active, -> { where(active: true) }

  def self.having_max_year_in_state(state)
    max_year = on_db(state.downcase.to_sym).active.maximum(:year)
    on_db(state.downcase.to_sym).where(year: max_year, data_type_id: 174).active
  end

end
