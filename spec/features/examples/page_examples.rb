require 'spec_helper'

shared_example 'should contain the expected text' do |text|
  fail unless subject.present?
  [*subject].each do | s |
    expect(s.text).to include(text)
  end
end
