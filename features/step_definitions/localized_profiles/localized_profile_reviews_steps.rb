Given /I filter(?: on)? (parents|students|all)/ do |filter|
  element = "#{filter}_filter"

  @page.element(element).click
  @page.wait_for_reviews
  @page.should have_at_least(1).reviews

  if filter.match /parents|students/
    @page.posters.each { |poster| poster.text.downcase.should include(filter[0..-2].downcase) }
  end

end
