# frozen_string_literal: true

require 'spec_helper'
require 'sitemap/sitemap_index_generator'

describe SitemapIndexGenerator do
  subject(:generator) { SitemapIndexGenerator.new }
  let(:current_date) { Time.new.strftime('%Y-%m-%d') }

  describe '#write_feed' do
    it 'writes out 53 sitemaps' do
      expect(generator).to receive(:write_sitemap).exactly(53).times
      generator.send(:write_feed)
    end

    context 'with a limited set of states to preserve spec author sanity' do
      before { expect(States).to receive(:abbreviations).and_return(%w(ak de)) }

      it 'writes out state links, misc link, and WP link' do
        expect(generator).to receive(:write_sitemap).with('https://www.greatschools.org/sitemap-https/sitemap-ak.xml')
        expect(generator).to receive(:write_sitemap).with('https://www.greatschools.org/sitemap-https/sitemap-de.xml')
        expect(generator).to receive(:write_sitemap).with('https://www.greatschools.org/sitemap-https/sitemap-misc.xml')
        expect(generator).to receive(:write_sitemap).with('https://www.greatschools.org/gk/sitemap_index.xml')
        generator.send(:write_feed)
      end
    end
  end
end