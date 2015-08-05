#encoding: utf-8

class HeaderSection < SitePrism::Section
  element :in_spanish_link, 'a', text: 'En Español'
  element :in_english_link, 'a', text: 'In English'

  def switch_to_spanish
    in_spanish_link.click
  end

  def switch_to_english
    in_english_link.click
  end

  def switch_language
    (in_spanish_link || in_english_link).click
  end
end