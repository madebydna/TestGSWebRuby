require 'spec_helper'

describe '_details_overview.html.erb' do
  let(:basic_information) do
    {
      header: 'Test heading',
      data: {
        'Data point' => 'one, two, three'
      }
    }
  end
  before do
    render 'school_profile/data_layouts/details_overview', data: object
  end

  context 'when given an object that responds to #basic_information' do
    subject { rendered }
    let(:object) { double(basic_information: basic_information) }

    it { is_expected.to have_content 'Test heading' }
    it { is_expected.to have_content 'Data point' }
    it { is_expected.to_not have_content 'data' }
    it { is_expected.to_not have_content 'header' }
    it { is_expected.to have_content 'one, two, three' }
  end

end