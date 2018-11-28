# frozen_string_literal: true

require 'spec_helper'

describe StatesMetaTagsConcerns do
  subject(:state_module) do
    o = Object.new
    o.singleton_class.instance_eval { include StatesMetaTagsConcerns }
    o
  end

  context 'With state set to Arizona' do
    before { state_module.instance_variable_set(:@state, {:short => 'az', :long => 'arizona'}) }

    describe '#states_show_title' do
      subject { state_module.states_show_title }
      it { is_expected.to eql("2019 Arizona Schools | Arizona Schools | Public & Private Schools") }
    end

    describe '#states_show_description' do
      subject { state_module.states_show_description }
      it { is_expected.to eql("2019 Arizona school rankings, all AZ public and private schools in Arizona ranked. Click here for Arizona school information plus read ratings and reviews for Arizona schools.") }
    end
  end

  context 'With state set to New Jersey' do
    before { state_module.instance_variable_set(:@state, {:short => 'nj', :long => 'new jersey'}) }

    describe '#states_show_title' do
      subject { state_module.states_show_title }
      it { is_expected.to eql("2019 New Jersey Schools | New Jersey Schools | Public & Private Schools") }
    end

    describe '#states_show_description' do
      subject { state_module.states_show_description }
      it { is_expected.to eql("2019 New Jersey school rankings, all NJ public and private schools in New Jersey ranked. Click here for New Jersey school information plus read ratings and reviews for New Jersey schools.") }
    end
  end

  describe 'current year' do
    before { state_module.instance_variable_set(:@state, {:short => 'az', :long => 'arizona'}) }
    it 'should be updated before 2020' do
      # If this fails then whoever currently owns our SEO strategy should be informed that these
      # title/meta tags are out of date. They wanted it to say 2019 when we launched in 2018
      # which is why we aren't using Time.now.year currently.
      expect(state_module.states_show_title.scan(/\d+/).first.to_i).to be >= Time.now.year
    end
  end
end
