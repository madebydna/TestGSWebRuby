# frozen_string_literal: true

require_relative('sitemap_index_generator')
require_relative('sitemap_misc_generator')
require_relative('sitemap_state_generator')

class SitemapGenerator
  def generate(output_dir)
    SitemapIndexGenerator.new(output_dir).write_feed
    SitemapMiscGenerator.new(output_dir).write_feed
    States.abbreviations.each do |state|
      SitemapStateGenerator.new(output_dir, state).write_feed
    end
  end
end