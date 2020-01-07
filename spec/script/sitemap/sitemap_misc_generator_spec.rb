# frozen_string_literal: true

require 'spec_helper'
require 'sitemap/sitemap_misc_generator'

describe SitemapMiscGenerator do
  subject(:generator) { SitemapMiscGenerator.new('.') }

  describe '#write_feed' do
    it 'writes out homepage and boundary links' do
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/', 'monthly', '1.0')
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/school-district-boundaries-map/', 'monthly', '0.7')
      generator.send(:write_feed)
    end
  end
end