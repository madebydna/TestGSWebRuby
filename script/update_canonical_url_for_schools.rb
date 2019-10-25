# frozen_string_literal: true

require 'optparse'
include Rails.application.routes.url_helpers
include UrlHelper

ARGV << '-h' if ARGV.empty?
script_args = {}

# states = States.abbreviations
states = %w(ak)
states.each do |state|
  School.on_db(state).where(canonical_url: nil).active.limit(5).each do |school|
    puts school.shard
    puts school_path(school)
    school.update!(canonical_url: school_path(school))
  end
end
