require 'remote_spec_helper'
require 'features/page_objects/home_page'

describe 'User visits Home Page', type: :feature, remote: true, safe_for_prod: true do
  before { visit home_path }
  subject(:page_object) { HomePage.new }
  context 'successfully' do
    it { is_expected.to have_header  }
  end
end
