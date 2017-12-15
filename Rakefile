# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  # defines a rake task called gk_black_box and sets rspec flags appropriately
  RSpec::Core::RakeTask.new(:gk_black_box, :host) do |t, task_args|
    ENV['CAPYBARA_HOST'] = task_args[:host] || 'https://qa.greatschools.org'
    ENV['CAPYBARA_PORT'] = '80'
    ENV['BLACK_BOX'] = 'true'
    t.rspec_opts = '--require spec_helper.rb --tag=remote --pattern="spec/qa/pages/gk/**{,/*/**}/*_spec.rb"'
  end
rescue LoadError
  puts "No rspec rake library found"
end
