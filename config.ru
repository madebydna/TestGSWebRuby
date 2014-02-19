# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if Rails.env.profile?
  profiling_directory =  Rails.root.join('profiling-results')
  Dir.mkdir profiling_directory unless File.exist? profiling_directory
  use Rack::RubyProf, :path => profiling_directory
end

run LocalizedProfiles::Application
