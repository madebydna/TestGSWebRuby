# frozen_string_literal: true

require 'features/page_objects/gk_vocabulary_milestones_page'

describe 'User visits GK high school milestones', type: :feature, remote: true, safe_for_prod: true do
  before { visit '/gk/category/milestones-topics/vocabulary/' }
  let(:page_object) { GkVocabularyMilestones.new }
  subject { page_object }
  its(:heading) { is_expected.to have_text('Vocabulary') }
  it { is_expected.to have_videos }
  its('videos.size') { is_expected.to eq(6) }
end
