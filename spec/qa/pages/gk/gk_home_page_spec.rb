# frozen_string_literal: true
require 'features/page_objects/gk_home_page'

describe 'User visits GK home', type: :feature, remote: true, safe_for_prod: true do
  subject(:page_object) { GkHomePage.new  }
  before { page_object.load }
  
  it { is_expected.to have_heading }
  its('heading.text') { is_expected.to be_present }
  it { is_expected.to have_subheadings }
  it { is_expected.to have_cue_cards }
  it { is_expected.to have_recommended_articles }
  its('recommended_articles.content_tiles.size') { is_expected.to eq(4) }
  it { is_expected.to have_newsletter_signup_section }
  it { is_expected.to have_footer }

  when_I :sign_up_for_newsletters do
    it { is_expected.to have_newsletter_success_modal }
  end
  
end
