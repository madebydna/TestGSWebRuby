class CreateSchoolCollections < ActiveRecord::Migration
  def change
    create_table :school_collections do |t|
      t.integer :school_id
      t.integer :collection_id

      t.timestamps
    end
  end
end
