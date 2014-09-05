class BarCharts::BasicBarChart < Draper::Decorator
  # Must be an array of hashes. Each hash must contain the labels/values
  # needed for the bar chart
  decorates :array
  delegate_all

  def config
    context[:config]
  end

  def bars
    config['bars']
  end

  def name
    # The name mentioned here gets passed to a JS function,
    # which then uses this name to look up the dimensions and other layout data
    'global'
  end

  def label_key
    (config['label_key'] || :label).to_sym
  end

  def google_bar_chart_array
    array.map { |hash| array_for_single_row(hash) }.compact
  end

  def bar_value(value)
    # Google bar chart requires values to be numerical. They will default to 0
    value.to_s.gsub(/<|=|>/,'').to_f.round
  end

  def display_value(value)
    string_value = value.to_s
    dv = value.to_f.round
    if string_value.match /<|=|>/
      dv = value
    end
    dv
  end

  def array_for_single_row(data_for_single_row)
    data_point_label = data_for_single_row[label_key]

    array_of_bar_arrays = bars.map do |column_config|
      # The key that we can use to index into the "data hash". e.g. "state_value"
      column_key = column_config['key'].to_sym
      column_label = column_config['label']
      column_format = column_config['format']

      bar_value = 0
      bar_annotation = ''
      bar_tooltip = ''

      if data_for_single_row[column_key].present?
        bar_value = bar_value(data_for_single_row[column_key])
        bar_annotation = bar_value.to_s
        if column_format == 'percentage'
          bar_annotation << '%'
        end
        bar_tooltip = bar_chart_tooltip_html(data_point_label, column_label, bar_annotation)
      end

      [bar_value, bar_annotation, bar_tooltip]
    end

    [data_point_label] + array_of_bar_arrays.inject([], &:+)
  end

  def script_tag(bar_chart_dom_id)
    bar_labels = bars.map { |config| config['label'] }
    if google_bar_chart_array.present?
      '<script>' +
      "GS.visualchart.drawBarChart(#{google_bar_chart_array}, '#{bar_chart_dom_id}', '#{name}', #{bar_labels});" +
      '</script>'
    end
  end

  def bar_chart_tooltip_html(data_point_label, bar_label, value)
    tooltip = "<div class='open-sans_b' style='width:100px;'>#{data_point_label}</div>#{bar_label}: #{value}"
    tooltip
  end

end