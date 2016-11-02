require 'spec_helper'
describe SchoolProfilesController do
  describe '#require_school' do
    subject { controller.send(:require_school) }

    it 'renders a 404 if no school is found' do
      allow(controller).to receive(:school).and_return(nil)
      expect(controller).to receive(:render).
          with('error/school_not_found', {layout: 'error', status: 404})
      subject
    end

    it 'redirects to city page if school is inactive' do
      allow(controller).to receive(:school).and_return(FactoryGirl.build(:inactive_school))
      expect(controller).to receive(:redirect_to).
          with('/california/alameda/', {:status=>:moved_permanently})
      subject
    end
  end
end