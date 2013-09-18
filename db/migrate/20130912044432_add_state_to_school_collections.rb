class AddStateToSchoolCollections < ActiveRecord::Migration
  using(:master)
  def self.up
    add_column :school_collections, :state, :string
  end
end
