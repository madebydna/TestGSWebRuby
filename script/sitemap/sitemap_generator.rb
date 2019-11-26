# frozen_string_literal: true

require_relative('sitemap_index_generator')
require_relative('sitemap_misc_generator')
require_relative('sitemap_state_generator')

class SitemapGenerator
  def generate
    SitemapIndexGenerator.new.write_feed
    SitemapMiscGenerator.new.write_feed
    States.abbreviations.each do |state|
      SitemapStateGenerator.new(state).write_feed
    end
  end
end