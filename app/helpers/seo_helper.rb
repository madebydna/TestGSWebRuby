module SeoHelper
  def partner_page_meta_keywords(page_name, acro_name)
    result = ""
    result << page_name << ", "
    result << page_name << " partnership, "

    if acro_name.blank?
      result << page_name << " GreatSchools partnership"
    else
      result << acro_name << " partnership, "
      result << page_name << " GreatSchools partnership, "
      result << acro_name << " GreatSchools partnership"
    end
    result
  end

  def partner_page_description(page_name)
    "GreatSchools has partnered with #{page_name} to help you explore your options and find the right school for your child."
  end
end
