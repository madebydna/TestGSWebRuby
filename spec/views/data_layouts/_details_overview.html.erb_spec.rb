require 'spec_helper'

describe '_details_overview.html.erb' do
  let(:data) do
    {
        "Before/After Care" => ['Before care'],
        "Dress Code" => ['Uniform'],
        "Transportation" => ['Buses / vans provided for students'],
        "Academic Focus" => ['Business, Special Ed, Technology'],
        "Arts" => ['Computer animation, Graphics, Video and Film'],
        "World Languages" => ['French, German, Spanish, Hungarian, Polish'],
        "Student Demographics" => {
            "Hispanic" => 88,
            "Black" => 7,
            "White" => 2,
            "Asian/Pacific Islander" => 2,
            "2 or more races" => 1
        },
        "Free & reduced lunch participants" => 98,
        "Students w/ disabilities" => 6,
        "English language learners" => 45,
    }
  end
  before do
    view.extend(UrlHelper)
    assign(:school, FactoryGirl.build(:alameda_high_school))
    render 'school_profile/data_layouts/details_overview', data: data
  end

  context 'when given a hash that has basic information data' do
    subject { rendered }

    it { is_expected.to have_content 'Before/After Care' }
    it { is_expected.to have_content 'Before care' }
    it { is_expected.to_not have_content 'English language learners' }
    it { is_expected.to_not have_content 'Student Demographics' }
    it { is_expected.to have_content 'Dress Code' }
  end

  context 'when given a hash that has bad data' do
    subject { rendered }

    let(:data) do
      {
          'foo' => 'bar'
      }
    end

    it { is_expected.to_not have_content 'foo' }
  end

end