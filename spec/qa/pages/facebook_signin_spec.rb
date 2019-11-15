require 'features/page_objects/join_page'

describe 'Facebook signin', remote: true do
  let(:join_page) { JoinPage.new }
  before { join_page.load }
  
  it 'should redirect to account page with user\'s name' do
     facebok_window = window_opened_by do
      join_page.facebook_button.click
     end
     within_window facebok_window do
      submit_facebook_adam
     end
     expect(page).to have_text('Adam')
     expect(page.current_path).to eq('/account/')
   end
end
