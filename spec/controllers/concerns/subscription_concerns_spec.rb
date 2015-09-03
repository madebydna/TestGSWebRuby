require 'spec_helper'

describe SubscriptionConcerns do
  let(:controller) { FakeController.new }
  let(:current_user) {FactoryGirl.create(:user)}

  before(:all) do
    class FakeController
      include SubscriptionConcerns 
    end
  end

  before(:each) do
    FakeController.send(:public, *FakeController.protected_instance_methods)
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(current_user).to receive(:has_subscription?).with('greatnews').and_return(true)
    allow(controller).to receive(:set_omniture_events_in_cookie)
    allow(controller).to receive(:set_omniture_sprops_in_cookie)
  end

  after(:each) { clean_models :gs_schooldb, User }
  after(:each) { clean_models :ca, School }
  after(:all) { Object.send :remove_const, :FakeController }

  describe '#create_subscription' do
    before do 
      allow(controller).to receive(:set_flash_notice)
      allow(controller).to receive(:flash_error)
      # allow(controller).to receive_message_chain(:flash,:empty?).and_return(false)
    end

    context 'with no list parameter' do
      let(:school) { FactoryGirl.build(:school) }
      before do
        allow(School).to receive(:find_by_state_and_id).with('CA','1').and_return(school)
        allow(current_user).to receive(:has_subscription?).with('mystat', school).and_return(false)
      end

      context 'with one school in parameters' do
        let(:subscription_params) do
          {
            school_id: '1',
            state: 'CA',
          }
        end
        it 'should suscribe user to one school' do
          expect(current_user).to receive(:add_subscription!).with('mystat',school)
          subject.create_subscription(subscription_params)
        end
      end

      context 'with multiple schools in parameters' do
        context 'with valid parameters' do
          let(:subscription_params) do
            {
              school_id: '1,2,3',
              state: 'CA,CA,CA',
            }
          end
          let(:school2) { FactoryGirl.build(:bay_farm_elementary_school) }
          let(:school3) { FactoryGirl.build(:emery_secondary) }

          before do
            allow(School).to receive(:find_by_state_and_id).with('CA','2').and_return(school2)
            allow(School).to receive(:find_by_state_and_id).with('CA','3').and_return(school3)
            allow(current_user).to receive(:has_subscription?).with('mystat', school2).and_return(false)
            allow(current_user).to receive(:has_subscription?).with('mystat', school3).and_return(false)
          end

          it 'should subscribe user to three schools' do
            expect(current_user).to receive(:add_subscription!).with('mystat',school)
            expect(current_user).to receive(:add_subscription!).with('mystat',school2)
            expect(current_user).to receive(:add_subscription!).with('mystat',school3)
            subject.create_subscription(subscription_params)
          end
        end
        context 'with invalid parameters' do
          let(:subscription_params) do
            {
              school_id: '1,2,3',
              state: 'CA,CA',
            }
          end
          let(:school2) { FactoryGirl.build(:bay_farm_elementary_school) }
          let(:school3) { FactoryGirl.build(:emery_secondary) }

          before do
            allow(School).to receive(:find_by_state_and_id).with('CA','2').and_return(school2)
            allow(School).to receive(:find_by_state_and_id).with('CA','3').and_return(school3)
            allow(current_user).to receive(:has_subscription?).with('mystat', school2).and_return(false)
            allow(current_user).to receive(:has_subscription?).with('mystat', school3).and_return(false)
          end

          it 'should raise Argument error' do
            error_message = "state and school_id mismatch school_ids count 3 with state count 2"
            expect(controller).to receive(:flash_error).with(error_message)
            subject.create_subscription(subscription_params)
          end
        end
      end

      context 'with list parameters' do
        let(:subscription_params) do
          {
            list: 'sponsor'
          }
        end
        before do
          allow(current_user).to receive(:has_subscription?).with('sponsor', nil).and_return(false)
        end
        it 'should subscribe user to list' do
          expect(current_user).to receive(:add_subscription!).with('sponsor', nil)
          subject.create_subscription(subscription_params)
        end
      end

    end
  end 

  describe '#set_flash_notice' do
    context 'flash is empty' do
      let(:flash) { double('empty?'=>true) }
      before { allow(controller).to receive(:flash).and_return(flash) }
        it 'should return message' do
          message = 'blah'
          expect(controller).to receive(:flash_notice).with(message)
          subject.set_flash_notice(message)
        end
        it 'should return default if message is nil' do
          expect(controller).to receive(:flash_notice).with("You've signed up to receive updates")
          subject.set_flash_notice(nil)
          # expect(controller.set_flash_notice(nil)).to eq("You've signed up to receive updates")
        end
      end
    end
  end

