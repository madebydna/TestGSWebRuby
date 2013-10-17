class SchoolMetadata < ActiveRecord::Base
  include StateSharding

  self.table_name='school_metadata'
  self.primary_keys = :school_id, :meta_key

  belongs_to :school

  #def self.all
  #  SchoolMetadata.using(:CA).all
  #end

  #def self.fetch_metadata(school)
  #  SchoolMetadata.using(school.state.to_sym).where(school_id: school.id).all
  #end
end