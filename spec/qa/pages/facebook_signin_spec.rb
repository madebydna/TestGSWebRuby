require 'remote_spec_helper'
  describe 'Facebook signin', type: :feature, remote: true, safe_for_prod: true do
   it 'account page should include user\'s name' do
     pending 'Facebook sign in needs love'
     sign_in_as_facebook_adam
     expect(page).to have_text('Adam')
     expect(page.current_path).to eq('/account/')
   end
 end
