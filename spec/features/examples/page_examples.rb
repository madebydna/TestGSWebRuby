require 'spec_helper'

shared_example 'should contain the expected text' do |text|
  fail unless subject.present?
  [*subject].each do | s |
    expect(s.text).to include(text)
  end
end


shared_example 'should have a link with' do |opts|
  expect(subject).to have_link(opts[:text], :href => opts[:href])
end

shared_example 'should have url path' do |path|
  expect(current_path).to eq(path)
end
