module ConfiguredTableHelper

  def td(label, value)
    output = "<td data-title=\"#{label}\">"

    if value.is_a? Array
      value.each do |val|
        output << val << '<br/>'
      end
    else
      output << value
    end

    output << '</td>'
    output.html_safe
  end

end