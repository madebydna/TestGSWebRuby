module SectionHelper
  def display_section_head_link(category_placement, link_text=nil)
    page_title = ['Reviews', 'Details', 'Quality']
    return_str = ''
    title = category_placement.title

    if title.present? && (page_title.include? title)
      return_str << '<div class="fr prm pt8">'
      return_str << '<a href="'+ title.downcase
      return_str << '/">'
      return_str << (link_text.nil? ? 'See all '+title.capitalize  : link_text)
      return_str << '</a>'
      return_str << '</div>'
    end
    return_str
  end
end