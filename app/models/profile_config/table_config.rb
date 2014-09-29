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

  def match_data(table_data)
    return [] if @config['boxes'].nil?

    @config['boxes'].inject([]) do |array, box|
      table_data.rows.each do |row|
        if row[:key].match(box['key'])
          subject_count = row[:value].count
          subject_random = row[:value][rand(subject_count)]
          box_info = { :label => box['label'],
                       :icon => box['icon_css_class'],
                       :subject_count => subject_count,
                       :subject_random => subject_random }
          array << box_info
        end
      end
      array
    end

  end

  def round_value(column, value)
    precision = column['precision']
    if precision.present? && value.respond_to?(:round)
      value = value.round precision
    end
    value
  end

  def format(column, value)
    format = column['format']
    case format
      when 'percentage', 'percent'
        "#{value}%"
      else
        value
    end
  end

  # rounds and formats the value, based on how the given column is configured
  def column_value(column, value)
    if value.is_a?(Numeric)
      value = round_value(column, value)
    end
    round_value(column, value)
  end

  def row_values(columns, hash)

    columns.each_with_index do |column, index|
      if hash[column['key'].to_sym]
        label = column['label']
        unformatted_value = value = hash[column['key'].to_sym]
        if value.is_a? Array
          value.map { |value| format(column, value) }
        else
          unformatted_value = value = round_value column, value
          value = format column, value
        end

        yield label, value,unformatted_value
      else
        # TODO: clean up
        yield column['label'], column['default'] || 'N/A'
      end
    end

  end


end
