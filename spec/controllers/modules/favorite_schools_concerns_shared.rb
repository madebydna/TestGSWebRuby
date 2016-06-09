require 'spec_helper'

shared_examples_for 'a controller that can save a favorite school' do
  let(:user) { FactoryGirl.build(:user) }
  let(:school) { FactoryGirl.build(:school, state: 'ca') }
  subject do
    controller.send :add_favorite_school,
                    state: school.state,
                    school_id: school.id
  end

  shared_context 'when school already favorited' do
    before { allow(user).to receive(:favorited_school?).and_return true }
  end

  shared_context 'when school favorited successfully' do
    before { allow(user).to receive(:favorited_school?).and_return false }
  end

  shared_context 'when multiple schools favorited successfully' do |number_of_schools|
    before { allow(user).to receive(:favorited_school?).and_return false }
    subject do
      states = Array.new(number_of_schools).fill('CA')
      school_ids = (1..number_of_schools).to_a
      controller.send :add_favorite_school,
                      state: states.join(','),
                      school_id: school_ids.join(',')
    end
  end

  shared_context 'when something goes wrong' do
    subject { controller.send :add_favorite_school, {} rescue nil }
  end

  shared_example 'should not save the school as a favorite' do
    expect(user).to_not receive(:add_favorite_school!)
    subject
  end

  shared_example 'should set omniture data' do
    expect(controller).to receive :set_omniture_events_in_cookie
    expect(controller).to receive :set_omniture_sprops_in_cookie
    subject
  end

  shared_example 'should set omniture data multiple times' do |number_of_times|
    expect(controller).to receive(:set_omniture_events_in_cookie).exactly(number_of_times).times
    expect(controller).to receive(:set_omniture_sprops_in_cookie).exactly(number_of_times).times
    subject
  end

  shared_example 'should not set omniture data' do
    expect(controller).to_not receive :set_omniture_events_in_cookie
    expect(controller).to_not receive :set_omniture_sprops_in_cookie
    subject
  end

  shared_example 'should set flash notice' do
    expect(controller).to receive :flash_notice
    expect(controller).to_not receive :flash_error
    subject
  end

  shared_example 'should flash an error' do
    expect(controller).to_not receive :flash_notice
    expect(controller).to receive :flash_error
    subject
  end


  describe '#add_favorite_school' do
    let(:user) { FactoryGirl.build(:user) }
    let(:school) { FactoryGirl.build(:school, state: 'ca') }
    let(:school2) { FactoryGirl.build(:school, state: 'de') }

    before(:each) do
      allow(controller).to receive(:current_user).and_return user
      allow(School).to receive(:find_by_state_and_id).and_return school
    end

    with_shared_context 'when school already favorited' do
      include_examples 'should not save the school as a favorite'
    end

    with_shared_context 'when school favorited successfully' do
      include_examples 'should set omniture data'
      include_examples 'should set flash notice'
    end

    with_shared_context 'when multiple schools favorited successfully', 2 do
      include_examples 'should set omniture data multiple times', 2
      include_examples 'should set flash notice'
    end

    with_shared_context 'when something goes wrong' do
      include_examples 'should not set omniture data'
      include_examples 'should flash an error'
    end

    it 'should fail gracefully if school not found' do
      pending 'TODO: Flash error in controller instead of raise error'
      fail
      expect(user).to_not receive(:add_favorite_school!)
      expect(controller).to receive :flash_error
      controller.send :add_favorite_school, {}
    end

  end
end
