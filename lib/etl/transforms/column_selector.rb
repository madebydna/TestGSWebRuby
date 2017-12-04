require_relative '../step'

class ColumnSelector < GS::ETL::Step

  def initialize(*columns_selected)
    self.columns_selected = columns_selected
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
   record(row, :columns_removed) if original_columns != row.keys
   row
 end

 def event_key
   "Columns selected: #{@columns_selected.map(&:to_s).join(' ,')}"
 end

 def description
   "#{super}\n" + @columns_selected.join("\n - ")
 end

 def columns_selected=(columns)
   unless columns.is_a?(Array) && columns.size > 0
     raise ArgumentError.new('Columns must be a non-empty array')
   end
   columns.each_with_index do |column, index|
     unless [String, Symbol, Regexp].include?(column.class)
       raise ArgumentError.new("Columns must be an array of "\
                               "columns(Strings or Symbols) or regexes, "\
                               "but columns[#{index}] is a #{columns[index].class}")
     end
   end
   @columns_selected = columns
 end

end
