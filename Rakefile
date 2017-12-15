# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  # defines a rake task called gk_black_box and sets rspec flags appropriately
  RSpec::Core::RakeTask.new(:gk_black_box, :host) do |t, task_args|
    ENV['CAPYBARA_HOST'] = task_args[:host] if task_args[:host]
    t.rspec_opts = '--require remote_spec_helper.rb --tag=remote --pattern="spec/qa/pages/gk/**{,/*/**}/*_spec.rb"'
  end
rescue LoadError
  puts "No rspec rake library found"
end
