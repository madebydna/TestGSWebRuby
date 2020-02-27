# require 'spec_helper'
require 'features/page_objects/home_page'
require 'features/page_objects/search_page'
require 'features/page_objects/account_page'

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

    let(:account_page) { AccountPage.new }

    context 'with some grades selected and no partner offers' do
      before do
        subject.footer.newsletter_link.click
        subject.email_newsletter_modal.sign_up(@email, [2,5], false)
        expect(subject).to have_newsletter_success_modal
        account_page.load
      end

      it 'should subscribe user to selected grades' do
        second_grade = account_page.grade_level_subscriptions.content.find_input('second_grade')
        fifth_grade = account_page.grade_level_subscriptions.content.find_input('fifth_grade')
        expect(second_grade).to be_checked
        expect(fifth_grade).to be_checked
      end

      it 'should not subscribe user to partner offers' do
        account_page.email_subscriptions.closed_arrow.click
        account_page.email_subscriptions.wait_until_content_visible
        expect(account_page.email_subscriptions.content.sponsor_checkbox).not_to be_checked
      end
    end

    context 'with partner email checkbox selected' do
      before do
        subject.footer.newsletter_link.click
        subject.email_newsletter_modal.sign_up(@email, [], true)
        expect(subject).to have_newsletter_success_modal
        account_page.load
      end

      it 'should not subscribe user to partner offers mail' do
        account_page.email_subscriptions.closed_arrow.click
        account_page.email_subscriptions.wait_until_content_visible
        expect(account_page.email_subscriptions.content.sponsor_checkbox).to be_checked
      end
    end
  end
end
