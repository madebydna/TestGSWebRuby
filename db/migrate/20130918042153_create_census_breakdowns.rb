class CreateCensusBreakdowns < ActiveRecord::Migration
  def change
    create_table :census_breakdowns do |t|
      t.integer :datatype_id
      t.string :description

      t.timestamps
    end
  end
end
