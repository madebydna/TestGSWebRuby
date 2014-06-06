require 'spec_helper'

shared_examples_for 'page with state footer features' do |state|
  feature 'state specific footer' do
    before(:each) do
      alt = { short: 'NY', long: 'New York' }
      alt = { short: 'TX', long: 'Texas' } if state[:short] == 'NY'
      @city = FactoryGirl.create(
        :city,
        name: "A city in #{state[:long]}",
        state: state[:short]
      )
      @alt_city = FactoryGirl.create(
        :city,
        name: "A city in #{alt[:long]}",
        state: alt[:short]
      )
      @state = state
    end
    after(:each) do
      clean_models City
    end
    scenario 'should contain cities for current state' do
      expect(subject).to have_content("Find the great schools in #{@state[:long]}")
      expect(subject).to have_content(@city.name)
      expect(subject).to_not have_content(@alt_city.name)
    end
  end
end
