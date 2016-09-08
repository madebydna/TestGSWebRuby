require 'spec_helper'

describe '_details_overview.html.erb' do
  let(:data) do
    {
        "Before / After care" => ['Before care'],
        "Dress policy" => ['Uniform'],
        "Transportation" => ['Buses / vans provided for students'],
        "Academic focus" => ['Business, Special Ed, Technology'],
        "Arts media" => ['Computer animation, Graphics, Video and Film'],
        "World languages" => ['French, German, Spanish, Hungarian, Polish'],
        "Student ethnicity" => {
            "Hispanic" => 88,
            "Black" => 7,
            "White" => 2,
            "Asian/Pacific Islander" => 2,
            "2 or more races" => 1
        },
        "Free or reduced lunch" => { 'All students' => 78 },
        "Students with disabilities" => { 'All students' => 6 },
        "English language learners" => { 'All students' => 45 },
    }
  end
  before do
    view.extend(UrlHelper)
    assign(:school, FactoryGirl.build(:alameda_high_school))
    render 'deprecated_school_profile/data_layouts/details_overview', data: data
  end

  context 'when given a hash with school details data' do
    subject { rendered }

    it { is_expected.to have_content 'Before / After care' }
    it { is_expected.to have_content 'Before care' }
    it { is_expected.to have_content 'English language learners' }
    it { is_expected.to have_content 'Student Demographics' }
    it { is_expected.to have_content 'Dress policy' }
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
