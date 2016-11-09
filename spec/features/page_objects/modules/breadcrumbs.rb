module Breadcrumbs
  class BreadcrumbsSection < SitePrism::Section
    element :breadcrumb_link, 'a'
  end

  def self.included(page_class)
    page_class.class_eval do
      sections :breadcrumbs, BreadcrumbsSection, '.breadcrumbs'

      def has_breadcrumb
        breadcrumbs.present?
      end
    end
  end
end