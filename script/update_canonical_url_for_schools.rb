# frozen_string_literal: true

require 'optparse'
include Rails.application.routes.url_helpers
include UrlHelper

ARGV << '-h' if ARGV.empty?
script_args = {}

states = States.state_hash.values
states.each do |state|
  School.on_db(state) do 
    School.active.where(canonical_url: nil).each do |school|
      # done this way since ActiveRecord#update and ActiveRecord#update_attributes seems bugged
      school.canonical_url  = school_path(school, trailing_slash: true)
      school.save
    end
  end
end
