class CitiesController < ApplicationController
  def show
    # Stub data
    @breakdown_results = [
      { contents: 'Preschools', count: 10, hrefXML: 'http://google.com' },
      { contents: 'Elementary Schools', count: 20, hrefXML: 'http://google.com' },
      { contents: 'Middle Schools', count: 30, hrefXML: 'http://google.com' },
      { contents: 'High Schools', count: 10, hrefXML: 'http://google.com' },
      { contents: 'Public Schools', count: 50, hrefXML: 'http://google.com' },
      { contents: 'Private Schools', count: 50, hrefXML: 'http://google.com' },
      { contents: 'Charter Schools', count: 40, hrefXML: 'http://google.com' },
    ]
  end
end
