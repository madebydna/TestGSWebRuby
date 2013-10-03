# More specific step definition
# Step knows what kind of page object to get
# Step can contain expectations specific to the page
# Given /^I am on "([^\"]+)" localized school profile$/ do |page_name|
#   @page = GsPage.find page_name
#   @page.should be_displayed
# end


# step to handle visiting any page
# requires more rigid naming conventions / scenario steps
# sets expectations any page would need to adhere to
# pages that legitimately require different expectations could override methods in GsPage
Given /^I visit ([^\"]+)(?: page)?$/ do |page_name|
  @page = GsPage.visit page_name
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

Given /I filter(?: on)? (parents|students|all)/ do |filter|
  filter << '_filter'
  @page.element(filter).click
end

