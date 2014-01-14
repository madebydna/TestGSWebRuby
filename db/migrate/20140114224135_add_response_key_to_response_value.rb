class AddResponseKeyToResponseValue < ActiveRecord::Migration
  def change
    add_column :response_values, :response_key, :string
  end
end
