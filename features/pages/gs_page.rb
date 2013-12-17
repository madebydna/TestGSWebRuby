class GsPage < SitePrism::Page

  include RSpec::Matchers

  # Maps patterns to Page Objects defined in this features/pages directory
  # If you're adding brand new pages or brand new Page Object, add a regex to PageObject mapping here
  PAGE_MAPPING = {
      /localized( school)? profile( page)?$/i => :LocalizedProfilePage,
      /localized( school)? profile reviews( page)?$/i => :LocalizedProfileReviewsPage,
      /localized signin( page)?$/i => :LocalizedProfileSigninPage,
  }

  # ----------------------------------------------------------------------------------
  # Methods for working with page objects
  # ----------------------------------------------------------------------------------

  # Gets a page object and tells the page object to send the browser to the right URL
  def self.get_page(page_name)
    regex, symbol_or_page = PAGE_MAPPING.select{ |key, value| page_name.match key }.first

    raise "Could not find page matching #{page_name}" if symbol_or_page.nil?

    # memoize page object instance or each page mapping regex
    if symbol_or_page.instance_of? Symbol
      page = Object.const_get(symbol_or_page.to_s).new
      PAGE_MAPPING[regex] = page
    else
      page = symbol_or_page
    end

    # return the page object
    return page
  end

  def self.visit(page_name)

    # get a page object
    page = self.get_page page_name

    # tell the page to set its URL based on this page name
    page.switch_url page_name

    return page
  end

  # Switches the url and url matchers for the underlying page object.
  # This is so that a page object can be reused rather than reinstantiated
  def switch_url(page_name)

    # Get the regex and url for the first URL that matches
    # It will enumerate all of them, but code is clean
    regex, url = self.class::URLS.select{ |key, value| page_name.match key }.first

    # Oops, non matched.
    raise "Could not find page-specific URL matching #{page_name} for #{self.class}" if regex.nil?

    # Below methods available through SitePrism DSL
    self.class.set_url url
    self.class.set_url_matcher url.to_regexp(:literal => true)

    #directs the browser to this url
    load
  end

  # ----------------------------------------------------------------------------------
  # Extend SitePrism::Page with extra methods for working with elements
  # ----------------------------------------------------------------------------------

  def element_visible?(element_name)
    result = element(element_name)

    raise "Element '#{element_name}' not found on page #{self.class}" if result.nil?

    if result.is_a? Enumerable
      result.count > 0 && result.first.visible?
    else
      result.visible?
    end
  end

  def wait_for_element(element_name)
    element = lookup_element_name element_name

    raise "Element '#{element}' not defined for page #{self.class}" unless respond_to? element

    self.send "wait_for_#{element}"
  end

end