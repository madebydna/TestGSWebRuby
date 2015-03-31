require 'spec_helper'

shared_examples_for 'model with school association' do |klass = described_class, factory = klass.name.snakecase |

  it { is_expected.to respond_to(:school) }
  it { is_expected.to respond_to(:school_id) }
  it { is_expected.to respond_to(:school_state) }

  describe 'Class' do
    subject { klass }
    it { is_expected.to respond_to(:find_by_school) }
  end

  describe '.find_by_school' do
    let!(:school) { FactoryGirl.create(:alameda_high_school) }
    let!(:first) { FactoryGirl.create(factory, school_id: 9999, school_state: 'xx') }
    let!(:second) { FactoryGirl.create(factory, school_id: school.id, school_state: school.state) }
    let!(:third) { FactoryGirl.create(factory, school_id: 9998, school_state: 'xx') }
    let!(:fourth) { FactoryGirl.create(factory, school_id: school.id, school_state: school.state) }
    after do
      clean_models School
      clean_models klass
    end
    subject do
      klass.find_by_school(school)
    end
    it "should find #{klass.name.pluralize} with matching school" do
      expect(subject.size).to eq(2)
      expect(subject.first.id).to eq(second.id)
      expect(subject.last.id).to eq(fourth.id)
    end
    it "should not return inactive #{klass.name.pluralize}" do
      fourth.active = false
      fourth.save
      expect(subject.size).to eq(1)
      expect(subject.first.id).to eq(second.id)
    end
  end

  describe '#school' do
    let!(:school) { FactoryGirl.create(:alameda_high_school) }
    subject { FactoryGirl.build(factory, school_id: school.id, school_state: school.state) }
    it 'should find associated school' do
      expect(subject.school.id).to eq(school.id)
    end
  end

  describe '#school=' do
    let!(:school) { FactoryGirl.create(:alameda_high_school) }
    subject { FactoryGirl.build(factory, school_id: nil, school_state: nil) }
    it 'should set school_id to the correct value' do
      expect { subject.school = school }.to change { subject.school_id }.from(nil).to(school.id)
    end
    it 'should set school_state to the correct value' do
      expect { subject.school = school }.to change { subject.state }.from(nil).to(school.state)
    end
  end

end