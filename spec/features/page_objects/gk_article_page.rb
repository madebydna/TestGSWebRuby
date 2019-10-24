# frozen_string_literal: true

class GkArticlePage < SitePrism::Page
  
  set_url '/gk/articles{/slug}{?query*}'
  
  element :heading, 'h1'
  element :breadcrumbs, '.article-breadcrumb'
end
