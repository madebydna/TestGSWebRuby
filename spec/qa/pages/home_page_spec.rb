
require 'features/page_objects/home_page'

describe 'User visits Home Page', remote: true do
  subject(:home_page) { HomePage.new }
  before { home_page.load }
  context 'successfully' do
    it { is_expected.to have_header  }
  end
end
