# frozen_string_literal: true

require_relative 'sitemap_xml_writer'

class SitemapIndexGenerator < SitemapXmlWriter
  WORDPRESS_SITEMAP_URL = 'https://www.greatschools.org/gk/sitemap_index.xml'

  def initialize(output_dir)
    super
    @root_element = 'sitemapindex'
    @file_path = 'sitemap.xml'
    @schema = SITEMAP_INDEX_SCHEMA
  end

  def write_feed
    within_root_node do
      States.abbreviations.each do |state|
        write_sitemap("https://www.greatschools.org/sitemap-https/sitemap-#{state}.xml")
      end
      write_sitemap('https://www.greatschools.org/sitemap-https/sitemap-misc.xml')
      write_sitemap(WORDPRESS_SITEMAP_URL)
    end
    close_file
  end
end