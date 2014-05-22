require 'spec_helper'

feature "Join Page" do
  feature 'visiting the /login page' do
    before(:each) do
      clean_models User, SchoolRating
      clean_models :ca, School, SchoolMetadata
      visit join_path
    end
    after(:each) do
      clean_models User, SchoolRating
      clean_models :ca, School, SchoolMetadata
    end

    context 'when entering /gsr/login/#join into the search bar' do
      before { visit '/gsr/login/#join' }
      it 'should take the user to the login page' do
        expect(page.title).to eq('Log in to GreatSchools')
      end
      # this feature relies on javascript which for now our capybara tests cannot use
      # it 'should pre-select the create account tab' do
      #   expect(page).to have_css('js-join-tab active')
      # end
    end
  end
  feature 'submitting the join form with new email' do
    before(:each) do
      clean_models User, SchoolRating
      clean_models :ca, School, SchoolMetadata
      visit join_path
      fill_in 'join-email', with: 'ssprouse+testing@greatschools.org'
      check 'terms_terms'
      click_button 'Register email'
      @email = ActionMailer::Base.deliveries.last
    end
    after(:each) do
      clean_models User, SchoolRating
      clean_models :ca, School, SchoolMetadata
    end

    it 'creates a new user' do
      expect(User.with_email 'ssprouse+testing@greatschools.org')
        .to_not be_nil
    end

    it 'sends an email verification email' do
      expect(@email).to be_present
      expect(@email.subject)
        .to eq 'Please verify your email for GreatSchools'
    end

    it 'sends the email to the right person' do
      expect(@email.to).to include 'ssprouse+testing@greatschools.org'
    end

    feature 'email verification email' do
      it 'contains an email verification link' do
        expect(@email.body).to match verify_email_path
      end

      feature 'visiting the verification link' do
        let(:verification_link) { @email.body.match(/href=\"(.+)\"/)[1] }
        let(:user) { User.with_email 'ssprouse+testing@greatschools.org' }
        let(:review) {
          FactoryGirl.create(:school_rating,
            status: 'pp',
            user: user,
            school: FactoryGirl.create(:school, state: 'ca')
          )
        }
        subject(:visiting) { visit verification_link }

        it 'verifies the user\'s email' do
          expect{ subject }.to change{ user.reload; user.email_verified? }
            .from(false).to(true)
        end

        it 'removes the provisional status from the user' do
          expect{ subject }.to change{ user.reload; user.provisional? }
            .from(true).to(false)
        end

        it 'removes the provisional status from the user\'s reviews' do
          expect{ subject }.to change{ review.reload; review.status }
            .from('pp').to('p')
        end
      end
    end

  end
end
