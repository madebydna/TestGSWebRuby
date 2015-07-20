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
    data.each do |k, values|
      data[k] = values.select do |value|
        value[:breakdown].nil? || value[:breakdown].to_s.downcase == 'all students'
      end
    end
  end

end
