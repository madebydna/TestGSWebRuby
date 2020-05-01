# require 'spec_helper'
require 'features/page_objects/home_page'
require 'features/page_objects/search_page'
require 'features/page_objects/email_preferences_page'

describe 'User visits Home Page' do
  subject(:subject) { HomePage.new }
  before { subject.load }

  context 'successfully' do
    it { is_expected.to have_header  }
  end

  describe 'user can search for school', js: true do
    context 'succesfully' do
      before { skip }
      it { is_expected.to have_school_search_button }
      it { is_expected.to have_search_field }

      it 'should should display search page' do
        pending('failing potentially because of javascript')
        fail
        # subject.user_fill_in_school_search
        # subject.click_school_search
        # expect(SearchPage.new).to be_displayed
      end
    end
  end

  describe 'user can navigate to wordpress content', js: true do
    context 'succesfully' do
      before do
        pending('failing potentially because of javascript')
        fail
      end

      it { is_expected.to have_gk_link }

      it 'should have links to gk content' do
        subject.click_dropdown
        expect(subject.gk_content_dropdown).to have_content_links
      end

      it 'should have a link to Parenting' do
        subject.click_dropdown
        expect(subject.gk_content_dropdown.content_links.first.text).to eq( "Parenting")
      end
    end
  end

  describe 'signup via newsletter link', js: true do
    before { @email = random_email }
    after { clean_dbs(:gs_schooldb) }

    let(:preferences_page) { EmailPreferencesPage.new }

    context 'with some grades selected and no partner offers' do
      before do
        subject.footer.newsletter_link.click
        subject.email_newsletter_modal.sign_up(@email, [2,5], false)
        expect(subject).to have_newsletter_success_modal
        preferences_page.load
      end

      it 'should subscribe user to English weekly newsletter' do
        weekly = preferences_page.english.weekly
        expect(preferences_page.subscribed?(weekly)).to be true
      end

      it 'should have the English Grade by Grade checkbox checked' do
        grade_by_grade = preferences_page.english.grade_by_grade
        expect(preferences_page.subscribed?(grade_by_grade)).to be true
      end

      it 'should subscribe user to selected grades in English' do
        second_grade = preferences_page.english.grades.second_grade
        fifth_grade = preferences_page.english.grades.fifth_grade
        tenth_grade = preferences_page.english.grades.tenth_grade
        expect(preferences_page.subscribed?(second_grade)).to be true
        expect(preferences_page.subscribed?(fifth_grade)).to be true
        expect(preferences_page.subscribed?(tenth_grade)).to be false
      end

      it 'should not subscribe user to English partner offers' do
        sponsor = preferences_page.english.sponsor
        expect(preferences_page.subscribed?(sponsor)).to be false
      end
    end

    context 'with partner email checkbox selected' do
      before do
        subject.footer.newsletter_link.click
        subject.email_newsletter_modal.sign_up(@email, [], true)
        expect(subject).to have_newsletter_success_modal
        preferences_page.load
      end

      it 'should subscribe user to partner offers mail' do
        sponsor = preferences_page.english.sponsor
        expect(preferences_page.subscribed?(sponsor)).to be true
      end
    end

    context 'with teacher email checkbox selected' do

    end
  end
end
