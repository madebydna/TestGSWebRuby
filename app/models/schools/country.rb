class Country < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name='country'
  has_many :census_data_country_values, class_name: 'CensusDataCountryValue'
end