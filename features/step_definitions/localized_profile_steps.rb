# More specific step definition
# Step knows what kind of page object to get
# Step can contain expectations specific to the page
# Given /^I am on "([^\"]+)" localized school profile$/ do |page_name|
#   @page = GsPage.find page_name
#   @page.should be_displayed
# end

# If we don't yet have a page object, use page_name to get a page object
# Tell the page object to visit the right URL, based on page_name
def visit_page(page_name)
  if defined? @page
    @page.switch_url page_name
  else
    @page = GsPage.visit page_name
  end
end

# get a new page object given the provided page name
def visit_new_page(page_name)
  @page = GsPage.visit page_name
end

# step to handle visiting any page
# requires more rigid naming conventions / scenario steps
# sets expectations any page would need to adhere to
# pages that legitimately require different expectations could override methods in GsPage
Given /^I visit ([^\"]+)(?: page)?$/ do |page_name|
  visit_page page_name

  @page.should be_displayed

  # all pages should have some form of navigation
  @page.should have_navigation # doesn't check visibility

  # More examples:
  # @page.element_visible? 'navigation'
  # @page.navigation.visible?
end


Given /I see(?: the)? ([^\"]+)/ do |element_name|
  @page.element_visible? element_name
end

Given /I wait to see(?: the)? ([^\"]+)/ do |element_name|
  @page.wait_for_element element_name
  @page.element_visible? element_name
end

Given /I filter(?: on)? (parents|students|all)/ do |filter|
  element = "#{filter}_filter"

  @page.element(element).click
  @page.wait_for_reviews
  @page.should have_at_least(3).reviews

  if filter.match /parents|students/
    @page.posters.each { |poster| poster.text.should match(/#{filter[0..-2]}/i) }
  end

end
