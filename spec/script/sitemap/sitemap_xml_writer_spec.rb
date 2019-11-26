# frozen_string_literal: true

require 'spec_helper'
require 'sitemap/sitemap_xml_writer'

describe SitemapXmlWriter do
  subject(:writer) { SitemapXmlWriter.new('.') }

  let(:mock_builder) { double('XmlMarkup') }
  let(:expected_xml_output) { [] }
  let(:current_date) { Time.new.strftime('%Y-%m-%d') }

  before do
    allow(writer).to receive(:xml_builder).and_return(mock_builder)
    allow(mock_builder).to receive(:tag!) do |tagname, *args, &block|
      if !args.empty?
        expected_xml_output << "<#{tagname}>#{args.first}</#{tagname}>"
      elsif block.is_a?(Proc)
        expected_xml_output << "<#{tagname}>"
        block.call(mock_builder)
        expected_xml_output << "</#{tagname}>"
      end
    end
  end

  describe '#write_url' do
    it 'Writes out the expected structure' do
      writer.send(:write_url, 'https://www.greatschools.org/page/', 'daily', '1.0')
      expect(expected_xml_output).to eq([
                                            '<url>',
                                            '<loc>https://www.greatschools.org/page/</loc>',
                                            '<changefreq>daily</changefreq>',
                                            '<priority>1.0</priority>',
                                            "<lastmod>#{current_date}</lastmod>",
                                            '</url>'
                                        ])
    end
  end

  describe '#write_sitemap' do
    it 'Writes out the expected structure' do
      writer.send(:write_sitemap, 'https://www.greatschools.org/sitemap-https/sitemap-ca.xml')
      expect(expected_xml_output).to eq([
                                            '<sitemap>',
                                            '<loc>https://www.greatschools.org/sitemap-https/sitemap-ca.xml</loc>',
                                            "<lastmod>#{current_date}</lastmod>",
                                            '</sitemap>'
                                        ])
    end
  end
end