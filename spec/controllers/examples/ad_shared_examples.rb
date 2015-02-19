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
  include_examples 'sets specific google ad targeting attributes', %w[template]
  it 'sets the "compfilter" google ad targeting attribute to a a value in range (1..4)' do
    expect(subject.fetch('compfilter').to_i).to be_between(1,4)
  end
  it 'sets the "env" google ad targeting attribute to whatever is configured in env_global' do
    expect(subject.fetch('env')).to eq(ENV_GLOBAL['advertising_env'])
  end
end