class RenameSchoolsTableToSchool < ActiveRecord::Migration
  using(:master)
  def self.up
    rename_table :schools, :school
  end
  def self.down
    rename_table :school, :schools
  end
end
