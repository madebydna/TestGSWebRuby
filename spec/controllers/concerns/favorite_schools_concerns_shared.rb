require 'spec_helper'

shared_examples_for 'a controller that can save a favorite school' do

  describe '#add_favorite_school' do
    let(:user) { FactoryGirl.build(:user) }
    let(:school) { FactoryGirl.build(:school, state: 'ca') }
    let(:school2) { FactoryGirl.build(:school, state: 'de') }

    before(:each) do
      allow(controller).to receive(:current_user).and_return user
      allow(School).to receive(:find_by_state_and_id).and_return school
    end

    it 'should not save the favorite school if it\'s already favorited' do
      allow(user).to receive(:favorited_school?).and_return true

      expect(user).to_not receive(:add_favorite_school!)
      controller.send :add_favorite_school,
                      state: school.state,
                      school_id: school.id
    end

    it 'should fail gracefully if school not found' do
      pending 'TODO: Flash error in controller instead of raise error'
      fail
      expect(user).to_not receive(:add_favorite_school!)
      expect(controller).to receive :flash_error
      controller.send :add_favorite_school, {}
    end

    context 'when school favorited successfully' do
      before(:each) do
        allow(user).to receive(:favorited_school?).and_return false
      end

      after(:each) do
        controller.send :add_favorite_school,
                        state: school.state,
                        school_id: school.id
      end

      it 'should set omniture data' do
        expect(controller).to receive :set_omniture_events_in_cookie
        expect(controller).to receive :set_omniture_sprops_in_cookie
      end

      it 'should flash a notice' do
        expect(controller).to receive :flash_notice
        expect(controller).to_not receive :flash_error
      end
    end

    context 'when multiple school favorited successfully' do
      before(:each) do
        allow(user).to receive(:favorited_school?).and_return false
      end

      after(:each) do
        controller.send :add_favorite_school,
                        state: "#{school.state} #{school2.state}",
                        school_id: "#{school.id} #{school2.id}"
      end

      it 'should set omniture data' do
        expect(controller).to receive :set_omniture_events_in_cookie
        expect(controller).to receive :set_omniture_sprops_in_cookie
      end

      it 'should flash a notice' do
        expect(controller).to receive :flash_notice
        expect(controller).to_not receive :flash_error
      end
    end

    context 'when something goes wrong' do
      it 'should not set omniture data' do
        expect(controller).to_not receive :set_omniture_events_in_cookie
        expect(controller).to_not receive :set_omniture_sprops_in_cookie
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
