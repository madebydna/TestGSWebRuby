require 'spec_helper'

describe 'OSP Moderation Page' do
  before {clean_dbs(:gs_schooldb)}
  before {clean_models(:ca, School)}

  after {clean_dbs(:gs_schooldb)}
  after {clean_models(:ca, School)}


  scenario 'displays a table' do
    visit osp_moderation_index_path
    expect(page).to have_table('osp-table')
  end

  scenario 'has the right action buttons' do
    visit osp_moderation_index_path
    expect(page).to have_selector('button[data-id="approved"]')
    expect(page).to have_selector('button[data-id="rejected"]')
    expect(page).to have_selector('button[data-id="disabled"]')
    expect(page).to have_selector('button[data-id="osp-notes"]')
  end

  scenario 'has link to search osp requests' do
    visit osp_moderation_index_path
    expect(page).to have_link('Search OSP requests', href: "/admin/gsr/osp-search/" )
  end

end


