class CreatePageConfigs < ActiveRecord::Migration
  def change
    create_table :page_configs do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
