require 'spec_helper'

shared_examples_for 'a configurable profile page' do |action|
    before do
      allow(controller).to receive(:find_school).and_return(school)
      allow(PageConfig).to receive(:new).and_return(page_config)
      allow(page_config).to receive(:name).and_return(action)
    end

    it 'should set the correct cannonical url' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:canonical_url]).to be_present
    end

    it 'should set a PageConfig object' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:page_config]).to be_present
    end

    it 'should look up the correct school' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:school]).to eq(school)
    end

    it 'should 404 with non-existent school' do
      allow(controller).to receive(:find_school).and_return(nil)
      get action, controller.view_context.school_params(school)
      expect(response.code).to eq('404')
    end

    it 'should convert a full state name to a state abbreviation' do
      get action, controller.view_context.school_params(school)
      expect(assigns[:state]).to eq({ long: 'california', short: 'ca' })
    end
  end