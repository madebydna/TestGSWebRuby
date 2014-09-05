class CensusDataBreakdown < ActiveRecord::Base
  include LookupDataPreloading

  self.table_name = 'census_data_breakdown'
  self.inheritance_column = nil

  db_magic :connection => :gs_schooldb

  has_many :census_data_sets, :class_name => 'CensusDataSet', foreign_key: 'breakdown_id'

  preload_all :language, :as => :language, :foreign_key => 'language_id', :field => 'name'
  preload_all :ethnicity, :as => :ethnicity, :foreign_key => 'ethnicity_id', :field => 'name'

  def gender
    if attributes['gender'].nil?
      nil
    elsif attributes['gender'] == 'M'
      'Male'
    else
      'Female'
    end
  end

  def breakdown
    gender.presence || ethnicity.presence || language.presence
  end

end