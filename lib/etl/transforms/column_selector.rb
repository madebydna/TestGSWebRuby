require_relative '../step'

class ColumnSelector < GS::ETL::Step

  def initialize(*columns_selected)
    @columns_selected = columns_selected
  end

 def process(row)
   return row if @columns_selected.empty?
   original_columns = row.keys
   row.keep_if do |field, value|
     @columns_selected.any? do |match|
       match == field ||
         (match.is_a?(Regexp) && !!(match =~ field))
     end
   end
   record(:columns_removed) if original_columns != row.keys
   row
 end

 def event_key
   "Columns selected: #{@columns_selected.map(&:to_s).join(' ,')}"
 end

 def description
   "#{super}\n" + @columns_selected.join("\n - ")
 end

end
