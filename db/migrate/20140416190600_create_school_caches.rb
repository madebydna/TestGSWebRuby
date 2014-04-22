class CreateSchoolCaches < ActiveRecord::Migration
  def change
    create_table :school_cache do |t|
      t.integer :school_id
      t.string :name
      t.string :value
      t.string :state
      t.date :updated

      t.timestamps
    end
  end
end
