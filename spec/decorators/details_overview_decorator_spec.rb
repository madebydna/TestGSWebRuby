require 'spec_helper'

describe DetailsOverviewDecorator do
  subject do
    DetailsOverviewDecorator.new(data, school, view)
  end

  let(:data) do
    data = {
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

  let(:school) do
    school = FactoryGirl.build(:alameda_high_school)
  end

  let(:view) do
    double(school_details_path: 'foo.com')
  end


  describe '.initialize' do

    it { is_expected.to be_a(DetailsOverviewDecorator) }

    it 'should be an instance of DetailsOverviewDecorator' do
      expect(subject).to be_a(DetailsOverviewDecorator)
    end

    it 'should be an instance of DetailsOverviewDecorator' do
      expect(subject.instance_variable_get(:@data)).to eq(data)
    end

  end

  describe '#basic_information' do

    let(:basic_information_data) do
      {
        "header" => "BASIC INFORMATION",
        "data" => {
          "Before/After Care" => ['Before care'],
          "Dress Code" => ['Uniform'],
          "Transportation" => ['Buses / vans provided for students']
        },
        "link" => {
          "More" => 'foo.com'
        }
      }
    end

    it { is_expected.to respond_to(:basic_information) }

    it 'should return a hash' do
      expect(subject.basic_information).to be_a(Hash)
    end

    it 'should return transformed data' do
      expect(subject.basic_information).to eq(basic_information_data)
    end

    it 'should return a key called "link"' do
      expect(subject.basic_information).to have_key("link")
    end

    it 'should not return an empty hash' do
      expect(subject.basic_information["link"]).not_to be_empty
    end

    it 'should return a url' do
      expect(subject.basic_information["link"]["More"]).to eq('foo.com')
    end

    context 'when given bad data' do
      let(:data) do
        {
            'foo' => 'bar'
        }
      end

      it 'should return an empty hash' do
        expect(subject.basic_information).to be_empty
      end
    end

    context 'when given an empty hash' do
      let(:data) do
        {}
      end

      it 'should return an empty hash' do
        expect(subject.basic_information).to be_empty
      end
    end
  end

  describe '#has_basic_information_data?' do
    context 'when given bad data' do
      let(:data) do
        {
            'foo' => 'bar'
        }
      end

      it { is_expected.to_not have_basic_information_data }
    end

    context 'when given good data' do
      let(:data) do
        data = {
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

      it { is_expected.to have_basic_information_data }
    end
  end

  describe '#programs_and_culture' do

    let(:programs_and_culture_data) do
      {
        "header" => "PROGRAMS & CULTURE",
        "data" => {
          "Academic Focus" => ['Business, Special Ed, Technology'],
          "Arts" => ['Computer animation, Graphics, Video and Film'],
          "World Languages" => ['French, German, Spanish, Hungarian, Polish']
        },
        "link" => {
          "More program info" => 'foo.com'
        }
      }
    end

    it { is_expected.to respond_to(:programs_and_culture) }

    it 'should return a hash' do
      expect(subject.programs_and_culture).to be_a(Hash)
    end

    it 'should return transformed data' do
      expect(subject.programs_and_culture).to eq(programs_and_culture_data)
    end

    it 'should return a key called "link"' do
      expect(subject.programs_and_culture).to have_key("link")
    end

    it 'should not return an empty hash' do
      expect(subject.programs_and_culture["link"]).not_to be_empty
    end

    it 'should return a url' do
      expect(subject.programs_and_culture["link"]["More program info"]).to eq('foo.com')
    end

  end

  describe '#diversity' do

    let(:diversity_data) do
      {
        "header" => "DIVERSITY",
        "data" => {
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
        },
        "link" => {
          "More" => 'foo.com',
          "More diversity info" => 'foo.com'
        }
      }
    end

    it { is_expected.to respond_to(:diversity) }

    it 'should return a hash' do
      expect(subject.diversity).to be_a(Hash)
    end

    it 'should return transformed data' do
      expect(subject.diversity).to eq(diversity_data)
    end

    it 'should return a key called "link"' do
      expect(subject.diversity).to have_key("link")
    end

    it 'should not return an empty hash' do
      expect(subject.diversity["link"]).not_to be_empty
    end

    it 'should return a url' do
      expect(subject.diversity["link"]["More"]).to eq('foo.com')
    end

    it 'should return a url' do
      expect(subject.diversity["link"]["More diversity info"]).to eq('foo.com')
    end
  end

  # describe '#application_deadline' do
  #
  #   subject do
  #     EspEnrollmentDecorator.new(esp_enrollment_data).application_deadline
  #   end
  #
  #   context 'When application_deadline is "date"' do
  #     # MI 5874
  #     let(:esp_enrollment_data) do
  #       {
  #           'application_deadline' => 'date',
  #           'application_deadline_date' => '01/01/2020'
  #       }
  #     end
  #
  #     it 'it should return the actual date' do
  #       expect(subject).to eq 'January 01, 2020'
  #     end
end