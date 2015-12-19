require 'spec_helper'
require 'features/page_objects/forgot_password_page'
require 'features/page_objects/join_page'
require 'features/page_objects/reset_password_page'

describe 'Forgot password page' do

  subject(:page_object) do
    ForgotPasswordPage.new
  end

  before do
    visit '/account/forgot-password/'
  end

  after do
    clean_dbs(:gs_schooldb)
    clean_models :ca, School, SchoolMetadata
  end

  it { is_expected.to be_displayed }
  it { is_expected.to have_email_field }
  it { is_expected.to have_continue_button }

  context 'when I enter email that has no user', js: true do
    let (:user) { FactoryGirl.build(:user) }
    before do
      page_object.fill_in_email_field  user.email
    end

    when_I :click_continue_button do
      it 'should not display the join page' do
        expect(JoinPage.new).to_not be_displayed
      end
      it 'should display error message' do
        message = "There is no account associated with that email address. Would you like to join GreatSchools? x"
        expect(subject).to have_flash_errors(message)
      end
    end
  end
  context 'when I enter email for verfied user', js: true do
    let (:verified_user) { FactoryGirl.create(:verified_user) }
    before do
      page_object.fill_in_email_field  verified_user.email
    end
    when_I :click_continue_button do
      it 'should display the join page' do
        expect(JoinPage.new).to be_displayed
      end
      it 'should send reset password email' do
        expect(JoinPage.new).to be_displayed
        sent_email = ExactTarget.last_delivery_args
        expect(sent_email).to be_present
        expect(sent_email[:key]).to eq(ResetPasswordEmail.exact_target_email_key)
      end

      it 'sends the email to the right person' do
        expect(JoinPage.new).to be_displayed
        sent_email = ExactTarget.last_delivery_args
        expect(sent_email[:recipient]).to eq(verified_user.email)
      end

      context 'when I visit lost password link' do
        let(:review) {
          FactoryGirl.create(:review,
            active: false,
            user: verified_user,
            school: FactoryGirl.create(:school, state: 'ca')
          )
        }
        it 'should display the reset password page' do
          expect(JoinPage.new).to be_displayed
          sent_email = ExactTarget.last_delivery_args
          verification_link = sent_email[:attributes][:RESET_LINK] 
          visit verification_link
          expect(ResetPasswordPage.new).to be_displayed
        end
        it 'activates the the user\'s non-flagged reviews' do
          expect(JoinPage.new).to be_displayed
          sent_email = ExactTarget.last_delivery_args
          verification_link = sent_email[:attributes][:RESET_LINK] 
          # visit verification_link
          expect{ visit verification_link }.to change{ review.reload; review.active? }
            .from(false).to(true)
        end
      end
    end
  end

  context 'when I enter email for unverified user', js: true do
    let (:unverified_user) { FactoryGirl.create(:new_user) }
    before do
      page_object.fill_in_email_field  unverified_user.email
    end
    when_I :click_continue_button do
      it 'should display the join page' do
        expect(JoinPage.new).to be_displayed
      end
      it 'should send reset password email' do
        expect(JoinPage.new).to be_displayed
        sent_email = ExactTarget.last_delivery_args
        expect(sent_email).to be_present
        expect(sent_email[:key]).to eq(ResetPasswordEmail.exact_target_email_key)
      end

      it 'sends the email to the right person' do
        expect(JoinPage.new).to be_displayed
        sent_email = ExactTarget.last_delivery_args
        expect(sent_email[:recipient]).to eq(unverified_user.email)
      end

      context 'when I visit lost password link' do
        let(:review) {
          FactoryGirl.create(:review,
            active: false,
            user: unverified_user,
            school: FactoryGirl.create(:school, state: 'ca')
          )
        }
        it 'should display the reset password page' do
          expect(JoinPage.new).to be_displayed
          sent_email = ExactTarget.last_delivery_args
          verification_link = sent_email[:attributes][:RESET_LINK] 
          visit verification_link
          expect(ResetPasswordPage.new).to be_displayed
        end

        it 'verifies the user\'s email' do
          expect(JoinPage.new).to be_displayed
          sent_email = ExactTarget.last_delivery_args
          verification_link = sent_email[:attributes][:RESET_LINK] 
          expect{ visit verification_link }.to change{ unverified_user.reload; unverified_user.email_verified? }
            .from(false).to(true)
        end

        it 'removes the provisional status from the user' do
          expect(JoinPage.new).to be_displayed
          sent_email = ExactTarget.last_delivery_args
          verification_link = sent_email[:attributes][:RESET_LINK] 
          expect{ visit verification_link }.to change{ unverified_user.reload; unverified_user.provisional? }
            .from(true).to(false)
        end

        it 'activates the the user\'s non-flagged reviews' do
          expect(JoinPage.new).to be_displayed
          sent_email = ExactTarget.last_delivery_args
          verification_link = sent_email[:attributes][:RESET_LINK] 
          expect{ visit verification_link }.to change{ review.reload; review.active? }
            .from(false).to(true)
        end
      end
    end
  end

end
