class AddStateToSchoolCollections < ActiveRecord::Migration
  db_magic connection: :profile_config
  def self.up
    add_column :school_collections, :state, :string
  end
end
