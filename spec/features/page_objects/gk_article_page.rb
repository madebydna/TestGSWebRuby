# frozen_string_literal: true

class GkArticlePage < SitePrism::Page
  element :heading, 'h1'
  element :breadcrumbs, '.article-breadcrumb'

end
