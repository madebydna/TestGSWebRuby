class TableConfig

  def initialize(configJson)
    @config = configJson
  end

  def columns_to_print(table_data)
    @config['columns'].inject([]) do |array, column|

      if column['always_show'] || table_data.columns.include?(column['key'].to_sym)
        # ok, display the column.
        # the header and data, or just the data?
        if column['hide_header']
          column['display_type'] = :data_only
        else
          column['display_type'] = :data_and_header
        end
        array << column
      end

      array
    end
  end

end
