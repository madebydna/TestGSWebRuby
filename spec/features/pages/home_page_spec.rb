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
      it { is_expected.to have_school_search_field }

      it 'should should display search page' do
        pending('failing potentially because of javascript')
        fail
        subject.user_fill_in_school_search
        subject.click_school_search
        expect(SearchPage.new).to be_displayed
      end
    end
  end

  describe 'user can search for wordpress content', js: true do
    context 'succesfully' do
      before do
        pending('tests written but no code yet')
        fail
      end
      it { is_expected.to have_article_search_button }
      it { is_expected.to have_article_search_field }

      it 'should should display search page' do
        subject.user_fill_in_article_search
        subject.click_article_search
        expect(SearchPage.new).to be_displayed
      end
    end
  end
end
