# Knows how to parse a JSON representation of a Layout config in LocalizedProfile admin. Specifically for table layouts
class TableConfig
  attr_reader :config

  def initialize(configJson)
    @config = configJson.presence || {}
  end

  def columns_to_print(table_data)
    return [] if @config['columns'].nil?

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

  def format(column, value)
    precision = column['precision']
    if precision.present? && value.respond_to?(:round)
      value = value.round precision
    end

    format = column['format']
    case format
      when 'percentage', 'percent'
        value = "#{value}%"
      else
        value
    end
  end

  def row_values(columns, hash)

    columns.each do |column|
      if hash[column['key'].to_sym]
        label = column['label']
        value = hash[column['key'].to_sym]

        if value.is_a? Array
          value.map { |value| format(column, value) }
        else
          value = format column, value
        end

        yield label, value
      else
        # TODO: clean up
        yield column['label'], column['default'] || 'N/A'
      end
    end

  end


end
