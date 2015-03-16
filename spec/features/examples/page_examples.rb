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

%w[noindex nofollow noarchive].each do |value|
  shared_example("should have the #{value} meta tag") do
    robots_tag = subject.find('meta[name="robots"]', visible: false)
    csv = robots_tag.native.attributes['content'].value
    expect(csv).to be_present
    values = csv.split(',')
    values.each(&:strip!)
    expect(values).to include(value)
  end
end