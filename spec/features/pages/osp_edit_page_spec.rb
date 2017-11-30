require 'spec_helper'

describe 'Admin user' do
  after {clean_dbs(:gs_schooldb)}
  after {clean_models(:ca, School)}
  before do
    @user = create(:user)
    @school = create(:school)
    @esp_member = create(:esp_membership, member_id: @user.id, school_id: @school.id)
  end

  scenario 'displays osp edit page with school name' do
    visit osp_edit_path(@esp_member)
    expect(page).to have_content(@school.name)
  end

  scenario 'displays error message is user tries to save non-unique email' do
    user2 = create(:user, email: 'glass-toast@yum.com')
    visit osp_edit_path(@esp_member)
    fill_in 'user[email]', with: user2.email
    click_button 'Save'
    expect(page).to have_content('Sorry, but the email you chose has already been taken.')
  end

  scenario 'successfully saves unique email' do
    email = [*'0'..'9', *'a'..'z', *'A'..'Z'].sample(8).join + '@adt.com'
    until User.where(email: email).empty?
      email = [*'0'..'9', *'a'..'z', *'A'..'Z'].sample(8).join + '@adt.com'
    end
    visit osp_edit_path(@esp_member)
    fill_in 'user[email]', with: email
    click_button 'Save'
    expect(find_field('user[email]').value).to eq email
  end
end

