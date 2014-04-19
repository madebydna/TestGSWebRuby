class CreateSchoolCaches < ActiveRecord::Migration
  def change
    create_table :school_caches do |t|
      t.integer :school_id
      t.string :name
      t.string :value
      t.stringupdated :state

      t.timestamps
    end
  end
end
