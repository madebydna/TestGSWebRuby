require 'step'

class ColumnSelector < GS::ETL::Step

  def initialize(*columns_selected)
    @columns_selected = columns_selected
  end

 def process(row)
   original_columns = row.keys
   row.keep_if { |field, value| @columns_selected.include?(field) }
   record(:columns_removed) if original_columns != row.keys
   row
 end

 def event_key
   "Columns selected: #{@columns_selected.map(&:to_s).join(' ,')}"
 end

end
