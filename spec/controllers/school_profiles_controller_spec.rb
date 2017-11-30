require 'spec_helper'
describe SchoolProfilesController do
  describe '#require_school' do
    subject { controller.send(:require_school) }

    it 'redirects to city page if no school is found' do
      allow(controller).to receive(:school).and_return(nil)
      allow(controller).to receive(:state_param).and_return('new jersey')
      allow(controller).to receive(:city_param).and_return('east orange')
      expect(controller).to receive(:redirect_to).
          with('/new-jersey/east-orange/', {:status=>:found})
      subject
    end

    it 'redirects to city page if school is inactive' do
      allow(controller).to receive(:school).and_return(FactoryGirl.build(:inactive_school))
      expect(controller).to receive(:redirect_to).
          with('/california/alameda/', {:status=>:found})
      subject
    end
  end
end