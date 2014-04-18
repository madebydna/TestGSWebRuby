require 'spec_helper'

shared_examples_for 'a controller that can save a favorite school' do

  describe '#add_favorite_school' do
    let(:user) { FactoryGirl.build(:user) }
    let(:school) { FactoryGirl.build(:school, state: 'ca') }

    before(:each) do
      controller.stub(:current_user).and_return user 
      School.stub(:find_by_state_and_id).and_return school
    end

    it 'should not save the favorite school if it\'s already favorited' do
      user.stub(:favorited_school?).and_return true

      expect(user).to_not receive(:add_favorite_school!)
      controller.send :add_favorite_school,
                      state: school.state,
                      school_id: school.id
    end

    it 'should fail gracefully if school not found' do
      pending 'TODO: Flash error in controller instead of raise error'
      expect(user).to_not receive(:add_favorite_school!)
      expect(controller).to receive :flash_error
      controller.send :add_favorite_school, {}
    end

    context 'when school favorited successfully' do
      before(:each) do
        user.stub(:favorited_school?).and_return false
      end

      after(:each) do
        controller.send :add_favorite_school,
                        state: school.state,
                        school_id: school.id
      end

      it 'should set omniture data' do
        expect(controller).to receive :set_omniture_events_in_session
        expect(controller).to receive :set_omniture_sprops_in_session
      end

      it 'should flash a notice' do
        expect(controller).to receive :flash_notice
        expect(controller).to_not receive :flash_error
      end
    end

    context 'when something goes wrong' do
      it 'should not set omniture data' do
        expect(controller).to_not receive :set_omniture_events_in_session
        expect(controller).to_not receive :set_omniture_sprops_in_session
        controller.send :add_favorite_school, {} rescue nil
      end

      it 'should flash an error' do
        expect(controller).to receive :flash_error
        expect(controller).to_not receive :flash_notice
        controller.send :add_favorite_school, {} rescue nil
      end
    end

  end  
end