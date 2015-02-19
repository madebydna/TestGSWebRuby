require 'spec_helper'

shared_example 'sets at least one google ad targeting attribute' do
  expect(subject).to be_present
end

shared_example 'does not set any google ad targeting attributes' do
  expect(subject).to be_blank
end

shared_examples 'sets specific google ad targeting attributes' do |attributes_that_should_be_set|
  attributes_that_should_be_set.each do |attribute|
    it "sets the \"#{attribute}\" google ad targeting attribute" do
      expect(subject.fetch(attribute)).to be_present
    end
  end
end

shared_examples 'sets the base google ad targeting attributes for all pages' do
  attributes_for_all_pages = %w[env compfilter template]
  include_examples 'sets specific google ad targeting attributes', attributes_for_all_pages
end