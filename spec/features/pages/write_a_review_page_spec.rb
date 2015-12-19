require 'spec_helper'

feature 'Write a Review Page' do
  let(:school) { FactoryGirl.create(:school, city: 'St. Paul') }
  let!(:reviews_page) { FactoryGirl.create(:page, name: 'Reviews') }
  before do
    pending 'TODO: Remove after transition to topical reviews'
    fail
  end

  before(:all) do
    clean_models :ca, School
    clean_models SchoolRating, Page, User
  end
  after(:each) do
    clean_models :ca, School
    clean_models SchoolRating, Page, User
  end
  subject do
    visit school_review_form_path(school)
    page
  end

  feature 'User loads the page' do
    scenario 'It shows review form with title' do
      expect(subject).to have_content("Write a review about #{school.name}")
    end
    scenario 'It shows a star rating and says "Click on stars to rate"' do
      expect(subject).to have_css('.js-review-rating-stars')
      expect(subject).to have_content('Click on stars to rate')
    end
  end

  context 'when reviews are not pre-moderated' do
    context 'When registered user is logged in' do
      include_context 'signed in verified user'

      context 'and parent submits a valid review' do
        subject do
          visit school_review_form_path(school)
          page.select 'Parent', from: 'school_rating[affiliation]'
          fill_in 'school_rating[review_text]', with: 'test ' * 15
          find(:xpath, "//input[@name='school_rating[overall]']").set "3"
          check 'terms_terms'
          click_button('Submit your review')
          page
        end

        scenario 'User is redirected back to reviews profile page' do
          subject
          uri = URI.parse(current_url)
          expect(uri.path).to eq school_reviews_path(school)
        end

        scenario 'User sees the rating they submitted' do
          expect(subject).to have_css('.cuc_review span', text: '3')
        end

        scenario 'User sees the review they submitted' do
          expect(subject).to have_content 'test ' * 15
        end
      end
    end

    context 'When registered user is not logged in' do
      before do
        @user = FactoryGirl.create(:verified_user, password: 'password')
      end

      context 'and parent submits a valid review' do
        subject do
          visit school_review_form_path(school)
          page.select 'Parent', from: 'school_rating[affiliation]'
          fill_in 'school_rating[review_text]', with: 'test ' * 15
          find(:xpath, "//input[@name='school_rating[overall]']").set "3"
          check 'terms_terms'
          click_button('Submit your review')
          page
        end

        scenario 'User is redirected back to the signin page' do
          subject
          uri = URI.parse(current_url)
          expect(uri.path).to eq signin_path
        end

        context 'User signs in' do
          before do
            subject
            within('.js-signin-form') do
              fill_in 'email', with: @user.email
              fill_in 'password', with: 'password'
              click_button 'Login'
            end
          end

          scenario 'User is redirected back to reviews profile page' do
            subject
            uri = URI.parse(current_url)
            expect(uri.path).to eq school_reviews_path(school)
          end

          scenario 'User sees the rating they submitted' do
            expect(subject).to have_css('.cuc_review span', text: '3')
          end

          scenario 'User sees the review they submitted' do
            expect(subject).to have_content 'test ' * 15
          end
        end
      end
    end

    context 'With unregistered user' do
      context 'and parent submits a valid review' do
        subject do
          visit school_reviews_path(school)
          visit school_review_form_path(school)
          page.select 'Parent', from: 'school_rating[affiliation]'
          fill_in 'school_rating[review_text]', with: 'test ' * 15
          find(:xpath, "//input[@name='school_rating[overall]']").set "3"
          check 'terms_terms'
          click_button('Submit your review')
          page
        end

        before { subject }

        scenario 'User is redirected back to the signin page' do
          uri = URI.parse(current_url)
          expect(uri.path).to eq signin_path
        end

        context 'User registers for new account' do
          include_context 'user registers a new account'

          context 'user validates their email' do
            include_context 'user clicks link in the email verification email'

            scenario 'User is redirected back to reviews profile page' do
              uri = URI.parse(current_url)
              expect(uri.path).to eq school_reviews_path(school)
            end

            scenario 'User sees the rating they submitted' do
              expect(subject).to have_css('.cuc_review span', text: '3')
            end

            scenario 'User sees the review they submitted' do
              expect(subject).to have_content 'test ' * 15
            end
          end
        end
      end
    end
  end
end
