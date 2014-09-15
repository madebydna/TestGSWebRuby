module ConfiguredTableHelper

  def td(label, value, icon_css_class=nil)
    output = "<td data-title=\"#{label}\">"

    if icon_css_class.present?
      output << "<div style='width:60px; height: 55px;background-color: #000000'/>"
    end

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

end