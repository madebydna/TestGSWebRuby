# frozen_string_literal: true
require 'features/page_objects/gk_high_school_milestones_page'

describe 'User visits GK high school milestones', type: :feature, remote: true, safe_for_prod: true do
  subject { GkHighSchoolMilestones.new }
  before do
    subject.load
  end

  its(:heading) { is_expected.to have_text('MILESTONES') }
  it { is_expected.to have_videos }
  its('videos.size') { is_expected.to eq(13) }
end
