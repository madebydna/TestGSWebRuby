require 'spec_helper'

describe DetailsOverviewDecorator do
  subject do
    DetailsOverviewDecorator.new(data, school, view)
  end

  let(:data) do
    {
      "Before / After care"                 => ['Before care'],
      "Dress policy"                        => ['Uniform'],
      "Transportation"                    => ['Buses / vans provided for students'],
      "Academic focus"                    => ['Business, Special Ed, Technology'],
      "Arts"                              => ['Computer animation, Graphics, Video and Film'],
      "World languages"                   => ['French, German, Spanish, Hungarian, Polish'],
      "Student ethnicity"              => {
        "Hispanic"               => 88,
        "Black"                  => 7,
        "White"                  => 2,
        "Asian/Pacific Islander" => 2,
        "2 or more races"        => 1
      },
      "Free or reducted lunch" => 98,
      "Students with disabilities"        => 6,
      "English language learners"         => 45,
    }
  end

  let(:basic_information_data) do
    {
      "Before / After care" => 'Before care',
      "Dress policy"        => 'Uniform',
      "Transportation"    => 'Buses / vans provided for students'
    }
  end

  let(:programs_and_culture_data) do
    {
      "Academic focus"  => 'Business, Special Ed, Technology',
      "Arts"            => 'Computer animation, Graphics, Video and Film',
      "World languages" => 'French, German, Spanish, Hungarian, Polish'
    }
  end

  let(:diversity_data) do
    {
      "Student ethnicity" => {
          "Hispanic" => 88,
          "Black" => 7,
          "White" => 2,
          "Asian/Pacific Islander" => 2,
          "2 or more races" => 1
      },
      "Free or reducted lunch" => 98,
      "Students with disabilities" => 6,
      "English language learners" => 45,
    }
  end

  let(:school) do
    school = FactoryGirl.build(:alameda_high_school)
  end

  let(:view) do
    double(school_details_path: 'bar.com', school_quality_path: 'foo.com')
  end

  describe '.initialize' do

    it { is_expected.to be_a(DetailsOverviewDecorator) }

    it 'should return an instance variable called data' do
      expect(subject.instance_variable_get(:@data)).to eq(data)
    end

  end

  ["basic_information", "programs_and_culture", "diversity"].each do |action|
    describe "##{action}" do
      it { is_expected.to respond_to(action.to_sym) }



      describe "#has_#{action}_data?" do
        context 'when given bad data' do
          let(:data) do
            {
                'foo' => 'bar'
            }
          end

          it { is_expected.to_not send("have_#{action}_data".to_sym) }
        end
      end
    end
  end

  describe DetailsOverviewDecorator::BasicInformation do
    subject do
      DetailsOverviewDecorator::BasicInformation.new(data, urls)
    end

    let(:urls) do
      {
        :details => 'foo.com'
      }
    end

    describe '#header' do
      it 'should return the correct header' do
        expect(subject.header).to eq('BASIC INFORMATION')
      end
    end

    describe '#initialize' do
      it 'should return a hash' do
        expect(subject.data).to be_a(Hash)
      end
    end

    describe '#get_data' do
      it 'should return transformed data' do
        expect(subject.get_data).to eq(basic_information_data)
      end

      context 'when given bad data' do
        let(:data) do
          {
            'foo' => 'bar'
          }
        end

        it 'should return an empty hash' do
          expect(subject.get_data).to be_empty
        end
      end

      context 'when given an empty hash' do
        let(:data) do
          {}
        end

        it 'should return an empty hash' do
          expect(subject.get_data).to be_empty
        end
      end
    end

  end

  describe 'generated information methods' do
    it 'should return correct type of DetailsInformation' do
      expect(subject.basic_information).to be_a(DetailsOverviewDecorator::BasicInformation)
      expect(subject.programs_and_culture).to be_a(DetailsOverviewDecorator::ProgramsAndCulture)
      expect(subject.diversity).to be_a(DetailsOverviewDecorator::Diversity)
    end
  end

end
