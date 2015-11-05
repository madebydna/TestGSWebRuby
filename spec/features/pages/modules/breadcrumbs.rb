module Breadcrumbs
  class BreadcrumbsSection < SitePrism::Section
    element :title, 'span[itemprop="title"]'
    element :link, 'a'
  end

  def self.included(page_class)
    page_class.class_eval do
      sections :breadcrumbs, BreadcrumbsSection, 'span[itemtype="http://data-vocabulary.org/Breadcrumb"]'

      def nth_breadcrumb(n)
        breadcrumbs[n-1]
      end

      %w[first second third fourth fifth].each_with_index do |ordinal, index|
        send(:define_method, "#{ordinal}_breadcrumb") do
          breadcrumbs[index]
        end
      end

      def has_breadcrumb(position, text, href)
        breadcrumb = breadcrumbs[position]
        breadcrumb.title.present? &&
            breadcrumb.title.text == text &&
            breadcrumb.find('a', href: href)

      end
    end
  end
end