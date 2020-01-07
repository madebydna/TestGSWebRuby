# frozen_string_literal: true

require_relative 'sitemap_xml_writer'

class SitemapMiscGenerator < SitemapXmlWriter
  include Rails.application.routes.url_helpers

  def initialize(output_path)
    super
    @root_element = 'urlset'
    @file_path = "sitemap-misc.xml"
    @schema = SITEMAP_SCHEMA
  end

  def write_feed
    within_root_node do
      # Homepage
      write_url('https://www.greatschools.org/', 'monthly', '1.0')
      # School/District boundary map
      write_url('https://www.greatschools.org' + district_boundary_path(trailing_slash: true), 'monthly', '0.7')
    end
    close_file
  end
end