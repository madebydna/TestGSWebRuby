class CreateCensusDataSets < ActiveRecord::Migration
  def change
=begin
    create_table "census_data_set", :force => true do |t|
      t.integer "data_type_id",                                   :null => false
      t.integer "breakdown_id"
      t.string  "grade",        :limit => 0
      t.integer "subject_id"
      t.integer "year",                                           :null => false
      t.string  "level_code",   :limit => 0, :default => "e,m,h", :null => false
      t.integer "active",                                         :null => false
    end
=end
  end
end
