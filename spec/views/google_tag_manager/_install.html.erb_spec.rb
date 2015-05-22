require 'spec_helper'

describe 'google_tag_manager/_install' do

  context 'with no GTM container ID defined' do
    before do
      stub_const('ENV_GLOBAL', {})
      render partial: 'google_tag_manager/install'
    end

    it 'should not render the tag manager code' do
      expect(rendered).to_not have_content('script')
    end
  end
  context 'with a GTM container ID defined' do
    before do
      stub_const('ENV_GLOBAL', {'gtm_container_id' => 'abc123'})
      render partial: 'google_tag_manager/install'
    end

    it 'should render the tag manager code' do
      expect(rendered).to have_content('script')
    end
  end

end
