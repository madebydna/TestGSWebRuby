module SectionHelper
  def display_section_head_link(category_placement, link_text=nil, anchor=nil)
    page_titles = ['reviews', 'details', 'quality']
    return_str = ''

    title = category_placement.title
    data_config = category_placement.layout_config_json
    link_text ||= data_config['link_text']
    link_text ||= 'See all '+title.capitalize if title.present?

    link_page = data_config['link_page'] #admin configuration takes precedence
    link_page ||= category_placement.title

    anchor_link = data_config['anchor_link'] #admin configuration takes precedence
    anchor_link ||= anchor

    if link_text.present? && link_page.present? && (page_titles.include? link_page.downcase)
      return_str << '<div class="fr prm pt8">'
      return_str << section_header_link(link_page,link_text, anchor_link)

      return_str << '</div>'
    end
    return_str
  end

  def section_header_link(page, link_text, anchor_link)
    helper_name = 'school_'
    helper_name << "#{page.downcase}_" if page != 'overview'
    helper_name << 'path'
    if  anchor_link.present?
      path = self.send helper_name.to_sym, @school, anchor:anchor_link
    else
      path = self.send helper_name.to_sym, @school
    end

    link_to link_text,path
  end
end