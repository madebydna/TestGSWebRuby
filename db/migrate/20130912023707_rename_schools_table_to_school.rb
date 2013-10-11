class RenameSchoolsTableToSchool < ActiveRecord::Migration
  db_magic :connection => :profile_config
  def self.up
    rename_table :schools, :school
  end
  def self.down
    rename_table :school, :schools
  end
end
