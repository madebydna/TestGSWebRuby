class GsPage < SitePrism::Page
  public :element_exists?

  PAGE_MAPPING = {
      /localized( school)? profile( page)?$/i => :LocalizedProfilePage,
      /localized( school)? profile reviews( page)?$/i => :LocalizedProfileReviewsPage,
  }

  ##################################################
  # class methods
  ##################################################

  def self.get_page(page_name)
    regex, symbol_or_page = PAGE_MAPPING.select{ |key, value| page_name.match key }.first

    raise "Could not find page matching #{page_name}" if symbol_or_page.nil?

    if symbol_or_page.instance_of? Symbol
      symbol_or_page = Object.const_get(symbol_or_page.to_s).new
      PAGE_MAPPING[regex] = symbol_or_page
    end

    symbol_or_page.switch_url page_name
    return symbol_or_page
  end

  def self.visit(page_name)
    page = get_page page_name
    page.load
    return page
  end

  ##################################################
  # instance methods
  ##################################################

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
  end

  def element_visible?(element)
    # convert human-friend element with whitespace to
    element.gsub! /\s+/, '_'

    raise "Element '#{element}' not defined for page #{self.class}" unless respond_to? element

    result = self.send element
    result.visible?
  end

  def element(element)
    raise "Element '#{element}' not defined for page #{self.class}" unless respond_to? element
    self.send element
  end
end