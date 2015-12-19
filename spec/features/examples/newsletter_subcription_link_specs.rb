require 'spec_helper'

feature '/gsr/user/subscriptions' do
  after { clean_models User, Subscription }

  feature 'User can sign up for GS newsletter' do
    context 'with signed in registered user' do
      include_context 'signed in verified user'

      subject do
        visit create_subscription_from_link_path(list: 'gsnewsletter')
      end
      before { subject }

      it 'should have the added subscription' do
        expect(user.has_subscription?('greatnews')).to be_truthy
      end

      it 'should redirect user to home page' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq home_path
      end

      feature 'when user submits invalid params' do
        subject do
          visit create_subscription_from_link_path(list: 'blah')
        end

        it 'should redirect to home page' do
          uri = URI.parse(current_url)
          expect(uri.path).to eq home_path
        end

        it 'should have the added subscription' do
          expect(Subscription.count).to be 0
        end
      end
    end

    context 'with signed out registered user' do
      let(:user) { FactoryGirl.create(:verified_user, password: 'password') }

      subject do
        visit create_subscription_from_link_path(list: 'gsnewsletter')
        page
      end

      before { subject }

      it 'user should be taken their account page' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq my_account_path
      end

      before do
        find(:css, "#email").set(user.email)
        find(:css, "#password").set('password')
        click_button 'Login'
      end

      feature 'user logs in' do

        it 'should redirect user to home page' do
          uri = URI.parse(current_url)
          expect(uri.path).to eq my_account_path
        end

        it 'should have the added subscription' do
          expect(user.has_subscription?('greatnews')).to be_truthy
        end
      end
    end
  end
end