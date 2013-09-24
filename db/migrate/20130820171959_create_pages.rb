class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :parent_id

      t.timestamps
    end

    add_index :pages, :parent_id
  end
end
