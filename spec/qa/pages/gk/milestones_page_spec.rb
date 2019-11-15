# frozen_string_literal: true
require 'features/page_objects/gk_milestones_page'

describe 'User visits GK milestones', type: :feature, remote: true, safe_for_prod: true do
  subject { GkMilestones.new }
  before do
    subject.load
  end

  its(:heading) { is_expected.to have_text('Milestones') }
  its('grade_nav_circles.size') { is_expected.to eq(6) }
  it 'should have correct grades' do
    expect(subject.grade_nav_circles.map(&:text)).to eq(['K', '1st', '2nd', '3rd', '4th', '5th'])
  end
end
