require 'spec_helper'

describe 'OSP Moderation Page' do
  after {clean_dbs(:gs_schooldb)}
  after {clean_models(:ca, School)}
  # before do
  #   user = create(:user)
  #   school = create(:school)
  #   esp_member = create(:esp_membership, :with_provisional_status, member_id: user.id, school_id: school.id)
  # end

  before do
    visit osp_moderation_index_path
  end


  scenario 'displays a table' do
    expect(page).to have_table('osp-table')
  end

  scenario 'has the right action buttons' do
    expect(page).to have_selector('button[data-id="approved"]')
    expect(page).to have_selector('button[data-id="rejected"]')
    expect(page).to have_selector('button[data-id="disabled"]')
    expect(page).to have_selector('button[data-id="osp-notes"]')
  end

  scenario 'has link to search osp requests' do
    expect(page).to have_link('Search OSP requests', href: "/admin/gsr/osp-search/" )
  end

end
