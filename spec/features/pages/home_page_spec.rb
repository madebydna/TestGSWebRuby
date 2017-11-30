require 'spec_helper'
require 'features/page_objects/home_page'
require 'features/page_objects/search_page'

describe 'User visits Home Page' do
  before { visit home_path }
  subject(:page_object) { HomePage.new }
  context 'successfully' do
    it { is_expected.to have_header  }
  end

  describe 'user can search for school', js: true do
    context 'succesfully' do
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
end
