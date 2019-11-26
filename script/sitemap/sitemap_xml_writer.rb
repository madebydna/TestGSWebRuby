# frozen_string_literal: true

class SitemapXmlWriter

  attr_reader :file_path, :root_element, :schema, :current_date

  SITEMAP_INDEX_SCHEMA = 'https://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd'
  SITEMAP_SCHEMA = 'https://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd'

  def initialize
    @current_date = Time.new.strftime('%Y-%m-%d')
  end

  private

  def file
    @_file ||= File.open(@file_path, 'w')
  end

  def xml_builder
    @_xml_builder ||= begin
      xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
      xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
      xml
    end
  end

  def within_root_node
    xml_builder.tag!(
        @root_element,
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:schemaLocation' => "https://www.sitemaps.org/schemas/sitemap/0.9 #{@schema}",
        :xmlns => 'https://www.sitemaps.org/schemas/sitemap/0.9'
    ) do
      yield(xml_builder)
    end
  end

  def close_file
    file.close
  end

  def within_tag(tag_name)
    xml_builder.tag! tag_name do
      yield(xml_builder)
    end
  end

  def write_sitemap(url)
    within_tag('sitemap') do
      xml_builder.tag!('loc', url)
      xml_builder.tag!('lastmod', @current_date)
    end
  end

  def write_url(url, changefreq, priority)
    within_tag('url') do
      xml_builder.tag!('loc', url)
      xml_builder.tag!('changefreq', changefreq)
      xml_builder.tag!('priority', priority)
      xml_builder.tag!('lastmod', @current_date)
    end
  end
end