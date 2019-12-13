require 'features/page_objects/osp_landing_page'

describe 'OSP Landing page' do
  subject { OspLandingPage.new }

  before do
    subject.load
  end


  it 'should redirect to OSP form when school is selected'
    # Enter Grant in textbox
    # Click on first auto-suggested school
    # Confirm redirect


end