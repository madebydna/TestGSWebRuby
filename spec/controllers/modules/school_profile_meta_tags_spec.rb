require 'spec_helper'

describe SchoolProfileMetaTags do
  let(:school) { FactoryGirl.build(:alameda_high_school) }

  subject(:helper) { SchoolProfileMetaTags.new(school) }

  describe '#title' do
    subject { helper.title }

    it 'sets title correctly' do
      expect(subject).to eq('Alameda High School - Alameda, California - CA | GreatSchools')
    end

    it 'handles Washington, D.C.' do
      school.state = 'DC'
      expect(subject).to eq('Alameda High School - Washington, DC | GreatSchools')
    end
  end

  describe '#description' do
    subject { helper.description }

    it 'sets description correctly' do
      expect(subject).to eq 'Alameda High School located in Alameda, California - CA. Find Alameda High School test scores, student-teacher ratio, parent reviews and teacher stats.'
    end

    it 'handles Washington, D.C.' do
      school.state = 'DC'
      expect(subject).to eq 'Alameda High School located in Washington, DC. Find Alameda High School test scores, student-teacher ratio, parent reviews and teacher stats.'
    end

    it 'handles preschools' do
      school.level_code = 'p'
      expect(subject).to eq 'Alameda High School in Alameda, California (CA). Read parent reviews and get the scoop on the school environment, teachers, students, programs and services available from this preschool.'
    end

    it 'handles preschools in Washington, D.C.' do
      school.level_code = 'p'
      school.state = 'DC'
      expect(subject).to eq 'Alameda High School in Washington, DC. Read parent reviews and get the scoop on the school environment, teachers, students, programs and services available from this preschool.'
    end
  end

  describe '#keywords' do
    subject { helper.keywords }

    it 'sets keywords correctly' do
      expect(subject).to eq 'Alameda High School, Alameda High School Alameda, Alameda High School Alameda California, Alameda High School Alameda CA, Alameda High School California, Alameda High School overview'
    end

    it 'handles preschools' do
      school.level_code = 'p'
      expect(subject).to eq 'Alameda High School, Alameda High School Alameda, Alameda High School Alameda California, Alameda High School Alameda CA, Alameda High School California, Alameda High School overview'
    end
  end
end
