class SchoolMetadata < ActiveRecord::Base
  #octopus_establish_connection(:adapter => "mysql2", :database => "surveys")

  self.table_name='school_metadata'

  #def self.all
  #  SchoolMetadata.using(:CA).all
  #end

  #def self.fetch_metadata(school)
  #  SchoolMetadata.using(school.state.to_sym).where(school_id: school.id).all
  #end
end