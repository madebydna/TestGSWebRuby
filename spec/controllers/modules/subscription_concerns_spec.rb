require 'spec_helper'

describe SubscriptionConcerns do
  let(:controller) { FakeController.new }
  let(:current_user) {FactoryBot.create(:user)}

  before(:all) do
    class FakeController
      include SubscriptionConcerns
    end
  end

  before(:each) do
    FakeController.send(:public, *FakeController.protected_instance_methods)
    allow(controller).to receive(:current_user).and_return(current_user)
    #allow(current_user).to receive(:has_subscription?).with('greatnews').and_return(true)
    allow(controller).to receive(:set_omniture_events_in_cookie)
    allow(controller).to receive(:set_omniture_sprops_in_cookie)
  end

  after(:each) { clean_models :gs_schooldb, User }
  after(:each) { clean_models :ca, School }
  after(:all) { Object.send :remove_const, :FakeController }

  describe '#create_subscription' do
    let(:school) { FactoryBot.build(:school) }
    before do
      allow(controller).to receive(:flash_notice)
      allow(controller).to receive(:flash_error)
      allow(School).to receive(:find_by_state_and_id).with('CA','1').and_return(school)
    end

    context 'with no list parameter' do
      before do
        # allow(current_user).to receive(:has_subscription?).with('mystat', school).and_return(false)
      end

      context 'with one school in parameters' do
        let(:subscription_params) do
          {
            school_id: '1',
            state: 'CA',
            language: 'es'
          }
        end
        it 'should suscribe user to one school' do
          expect(current_user).to receive(:safely_add_subscription!).with('greatnews', school, 'es')
          expect(current_user).to receive(:safely_add_subscription!).with('mystat', school, 'es')
          subject.create_subscription(subscription_params)
        end
      end

      context 'with multiple schools in parameters' do
        context 'with valid parameters' do
          let(:subscription_params) do
            {
              school_id: '1,2,3',
              state: 'CA,CA,CA',
              language: 'en'
            }
          end
          let(:school2) { FactoryBot.build(:bay_farm_elementary_school) }
          let(:school3) { FactoryBot.build(:emery_secondary) }

          before do
            allow(School).to receive(:find_by_state_and_id).with('CA','2').and_return(school2)
            allow(School).to receive(:find_by_state_and_id).with('CA','3').and_return(school3)
            # allow(current_user).to receive(:has_subscription?).with('mystat', school2).and_return(false)
            # allow(current_user).to receive(:has_subscription?).with('mystat', school3).and_return(false)
          end

          it 'should subscribe user to three schools' do
            expect(current_user).to receive(:safely_add_subscription!).with('greatnews', school, 'en')
            expect(current_user).to receive(:safely_add_subscription!).with('mystat', school, 'en')
            expect(current_user).to receive(:safely_add_subscription!).with('greatnews', school2, 'en')
            expect(current_user).to receive(:safely_add_subscription!).with('mystat', school2, 'en')
            expect(current_user).to receive(:safely_add_subscription!).with('greatnews', school3, 'en')
            expect(current_user).to receive(:safely_add_subscription!).with('mystat', school3, 'en')
            subject.create_subscription(subscription_params)
          end
        end
        context 'with invalid parameters' do
          let(:subscription_params) do
            {
              school_id: '1,2,3',
              state: 'CA,CA',
              language: 'en'
            }
          end
          let(:school2) { FactoryBot.build(:bay_farm_elementary_school) }
          let(:school3) { FactoryBot.build(:emery_secondary) }

          before do
            allow(School).to receive(:find_by_state_and_id).with('CA','2').and_return(school2)
            allow(School).to receive(:find_by_state_and_id).with('CA','3').and_return(school3)
            # allow(current_user).to receive(:has_subscription?).with('mystat', school2).and_return(false)
            # allow(current_user).to receive(:has_subscription?).with('mystat', school3).and_return(false)
          end

          it 'should raise Argument error' do
            error_message = "state and school_id mismatch school_ids count 3 with state count 2"
            expect(controller).to receive(:flash_error).with(error_message)
            subject.create_subscription(subscription_params)
          end
        end
      end
    end

    context 'with list parameters' do
      context 'with a school parameter' do
        let(:subscription_params) do
          {
            list: 'mystat',
            school_id: '1',
            state: 'CA',
            language: 'en'
          }
        end
        before do
          # allow(current_user).to receive(:has_subscription?).with('mystat',school).and_return(false)
        end
        it 'should subscribe user to list' do
          expect(current_user).to receive(:safely_add_subscription!).with('greatnews', school, 'en')
          expect(current_user).to receive(:safely_add_subscription!).with('mystat', school, 'en')
          subject.create_subscription(subscription_params)
        end
      end
      context 'with no school parameters' do
        let(:subscription_params) do
          {
            list: 'sponsor',
            language: 'en'
          }
        end
        before do
          # allow(current_user).to receive(:has_subscription?).with('sponsor', nil).and_return(false)
        end
        it 'should subscribe user to list' do
          expect(current_user).to receive(:safely_add_subscription!).with('greatnews', nil, 'en')
          expect(current_user).to receive(:safely_add_subscription!).with('sponsor', nil, 'en')
          subject.create_subscription(subscription_params)
        end
      end
      context 'with no language parameter' do
        let(:subscription_params) do
          {
            list: 'mystat',
            school_id: '1',
            state: 'CA'
          }
        end
        it 'should subscribe user to list' do
          expect(current_user).to receive(:safely_add_subscription!).with('greatnews', school, nil)
          expect(current_user).to receive(:safely_add_subscription!).with('mystat', school, nil)
          subject.create_subscription(subscription_params)
        end
      end
    end
  end

  describe '#set_flash_notice' do
    context 'flash is empty' do
      let(:flash) { double('empty?'=>true) }
      before do
        allow(controller).to receive(:subscribe_actions).and_return([])
        allow(controller).to receive(:flash).and_return(flash)
      end
      it 'should return message' do
        message = 'blah'
        expect(controller).to receive(:flash_notice).with(message)
        subject.create_subscription(message: message)
      end
      it 'should return default if message is nil' do
        expect(controller).to receive(:flash_notice).with("You've signed up to receive updates")
        subject.create_subscription(message: nil)
      end
    end
  end
end

