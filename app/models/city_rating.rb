class CityRating < ActiveRecord::Base
  self.table_name = 'city_rating'

  scope :active, -> { where(active: true) }

  def self.get_rating(state, city_name)
    city_rating = CityRating.on_db(state.downcase.to_sym).active.where(city: city_name )
    city_rating.present? ? city_rating.first.rating : 'NR'
  end
end