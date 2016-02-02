require 'spec_helper'

describe DetailsOverviewDecorator do
  subject do
    DetailsOverviewDecorator.new(data, school, view)
  end

  let(:data) do
    {
      "Before/After Care"                 => ['Before care'],
      "Dress Code"                        => ['Uniform'],
      "Transportation"                    => ['Buses / vans provided for students'],
      "Academic Focus"                    => ['Business, Special Ed, Technology'],
      "Arts"                              => ['Computer animation, Graphics, Video and Film'],
      "World Languages"                   => ['French, German, Spanish, Hungarian, Polish'],
      "Student ethnicity"              => {
        "Hispanic"               => 88,
        "Black"                  => 7,
        "White"                  => 2,
        "Asian/Pacific Islander" => 2,
        "2 or more races"        => 1
      },
      "FRL" => 98,
      "Students with disabilities"        => 6,
      "English language learners"         => 45,
    }
  end

  let(:basic_information_data) do
    {
      "header" => "BASIC INFORMATION",
      "data"                => {
          "Before/After Care" => 'Before care',
          "Dress Code"        => 'Uniform',
          "Transportation"    => 'Buses / vans provided for students'
      },
      "link" => {
          "More" => 'foo.com'
      }
    }
  end

  let(:programs_and_culture_data) do
    {
        "header" => "PROGRAMS & CULTURE",
        "data" => {
            "Academic Focus"  => 'Business, Special Ed, Technology',
            "Arts"            => 'Computer animation, Graphics, Video and Film',
            "World Languages" => 'French, German, Spanish, Hungarian, Polish'
        },
        "link" => {
            "More program info" => 'foo.com'
        }
    }
  end

  let(:diversity_data) do
    {
        "header" => "DIVERSITY",
        "data" => {
            "Student ethnicity" => {
                "Hispanic" => 88,
                "Black" => 7,
                "White" => 2,
                "Asian/Pacific Islander" => 2,
                "2 or more races" => 1
            },
            "FRL" => 98,
            "Students with disabilities" => 6,
            "English language learners" => 45,
        },
        "link" => {
            "More" => 'foo.com',
            "More diversity info" => 'bar.com'
        }
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






      it 'should not return an empty hash' do
        expect(subject.send(action.to_sym)["link"]).not_to be_empty
      end

      context 'when given bad data' do
        let(:data) do
          {
              'foo' => 'bar'
          }
        end

        it 'should return an empty hash' do
          expect(subject.send(action.to_sym)).to be_empty
        end
      end

      context 'when given an empty hash' do
        let(:data) do
          {}
        end

        it 'should return an empty hash' do
          expect(subject.send(action.to_sym)).to be_empty
        end
      end

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
        expect(subject.header).to eq(basic_information_data['header'])
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

      it 'should return a key called "link"' do
        expect(subject.get_data).to have_key("link")
      end
    end


  end

  describe '#basic_information' do
    it 'should return transformed data when given basic information' do
      expect(subject.basic_information).to eq(basic_information_data)
      expect(subject.programs_and_culture).to eq(programs_and_culture_data)
      expect(subject.diversity).to eq(diversity_data)
    end
  end

  describe '#basic_information' do
    it 'should return a url' do
      expect(subject.basic_information["link"]["More"]).to eq('foo.com')
    end
  end
  
  describe '#programs_and_culture' do
    it 'should return a url' do
      expect(subject.programs_and_culture["link"]["More program info"]).to eq('foo.com')
    end
  end

  describe '#diversity' do
    it 'should return a url' do
      expect(subject.diversity["link"]["More"]).to eq('foo.com')
    end

    it 'should return a url' do
      expect(subject.diversity["link"]["More diversity info"]).to eq('bar.com')
    end
  end
end