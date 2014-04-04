class CreateSchoolProfileConfigurations < ActiveRecord::Migration
  def change
    create_table :school_profile_configurations do |t|
      t.string :state
      t.string :configuration_key
      t.string :value

      t.timestamps
    end
  end
end
