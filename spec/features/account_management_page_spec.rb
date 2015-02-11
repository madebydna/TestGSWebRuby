require 'spec_helper'

feature 'Account management page' do

  subject do
    visit manage_account_path
    page
  end

  after do
    clean_models :gs_schooldb,EspMembership, MemberRole, Role, Subscription
  end

  feature 'requires user to be logged in' do
    context 'when user is not logged in' do
      it 'should return to the login page' do
      end
    end
  end

  feature 'User is logged in' do
    include_context 'signed in verified user'

    scenario 'It displays change password link' do
      change_password_div = subject.first('div', text: /\AChange Password\z/)
      expect(change_password_div).to be_present
      expect(subject).to have_selector('form input[name=new_password]')
      expect(subject).to have_selector('form input[name=confirm_password]')
    end

    context 'when user has approved osp membership' do
      let!(:esp_membership) {FactoryGirl.create(:esp_membership,:with_approved_status,:member_id=> user.id )}
      scenario 'It displays link to edit osp' do
        expect(subject).to have_content('Edit School Profile')
      end
    end

    context 'when user has provisional osp membership' do
      let!(:esp_membership) {FactoryGirl.create(:esp_membership,:with_provisional_status,:member_id=> user.id,:school_id=>1,:state=> 'mi' )}
      scenario 'It displays link to edit osp' do
        expect(subject).to have_content('Edit School Profile')
      end
    end

    context 'when user is osp super user' do
      let!(:esp_superuser_role) {FactoryGirl.create(:role )}
      let!(:member_role) {FactoryGirl.create(:member_role,member_id: user.id,role_id:esp_superuser_role.id)}
      scenario 'It displays link to edit osp' do
        expect(subject).to have_content('Edit School Profile')
      end
    end


    context 'When user has subscriptions' do
      let!(:osp_subscription) {FactoryGirl.create(:subscription,list: 'osp',member_id: user.id)}
      let!(:gs_subscription) {FactoryGirl.create(:subscription,list: 'greatnews',member_id: user.id)}

      scenario 'It should display subscriptions with pretty long_names names if subscription product is present otherwise just the name' do
        pending('PT-1213: No longer applicable. Delete and make new spec coverage for account management page subscription functionality')
        expect(user.subscriptions.size).to eq(2)
        expect(subject).to have_content(Subscription.subscription_product('greatnews').long_name)
        expect(subject).to have_content('osp') #does not have a subscription product hardcoded, hence so long name
      end

      scenario 'user can unsubscribe ' do
        pending('PT-1213: No longer applicable. Delete and make new spec coverage for account management page subscription functionality')
        expect do
          begin
            subject.within(".js-subscription-#{osp_subscription.id}") {click_on("Unsubscribe")}
          rescue ActionView::MissingTemplate
            #no op. For some reason capybara does not look for subscriptions/destroy.js.erb and instead looks for subscriptions/destroy.erb
          end
        end.to change(user.subscriptions, :count).by(-1)

      end
    end
  end
end
