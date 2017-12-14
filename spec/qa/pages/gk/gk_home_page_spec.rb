# frozen_string_literal: true

require 'remote_spec_helper'
require 'features/page_objects/gk_home_page'

describe 'User visits GK home', type: :feature, remote: true, safe_for_prod: true do
  before { visit greatkids_home_path }
  let(:page_object) { GkHomePage.new }
  subject { page_object }
  
  it { is_expected.to have_heading }
  its('heading.text') { is_expected.to be_present }
  it { is_expected.to have_subheadings }
  its('subheadings.first.text') { is_expected.to be_present }
  it { is_expected.to have_cue_cards }
  it { is_expected.to have_recommended_articles }
  its('recommended_articles.content_tiles.size') { is_expected.to eq(4) }
  it { is_expected.to have_newsletter_signup_section }
  it { is_expected.to have_footer }
end
