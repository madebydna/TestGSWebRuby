module ConfiguredTableHelper

  def td(label, value)
    output = "<td data-title=\"#{label}\">"

    if value.is_a? Array
      value.each do |val|
        output << val.to_s << '<br/>' if value.present?
      end
    else
      output << value.to_s if value.present?
    end

    output << '</td>'
    output.html_safe
  end

  def filter_for_all_students(data)
    filter_by_breakdowns(['', 'all students'], data)
  end

  def filter_by_breakdowns(breakdowns, data)
    return data if breakdowns == 'all'
    data.deep_dup.each do |k, values|
      data[k] = values.select do |value|
        [*breakdowns].any? do |breakdown|
          value[:breakdown].to_s.downcase == breakdown
        end
      end
    end
  end
end
