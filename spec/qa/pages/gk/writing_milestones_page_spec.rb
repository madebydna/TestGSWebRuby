# frozen_string_literal: true
require 'features/page_objects/gk_writing_milestones_page'

describe 'User visits GK writing milestones', type: :feature, remote: true, safe_for_prod: true do
  subject { GkWritingMilestones.new }
  before do
    subject.load
  end
  its(:heading) { is_expected.to have_text('Writing') }
  it { is_expected.to have_videos }
  its('videos.size') { is_expected.to eq(21) }
  it { is_expected.to have_sidebar }

  it 'should have the right links in the sidebar' do
    expect(subject.sidebar.links.map(&:text)).to eq([
      'Kindergarten',
      '1st grade',
      '2nd grade',
      '3rd grade',
      '4th grade',
      '5th grade',
      'Middle School',
      'High School',
      'Reading',
      'Math',
      'Writing',
      'Speaking',
      'Life Skills'
    ])
  end
end
