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
    let!(:first) { FactoryGirl.create(factory, school_id: 9999, school_state: 'WY') }
    let!(:second) { FactoryGirl.create(factory, school_id: school.id, school_state: school.state) }
    let!(:third) { FactoryGirl.create(factory, school_id: 9998, school_state: 'WY') }
    let!(:fourth) { FactoryGirl.create(factory, school_id: school.id, school_state: school.state) }
    after do
      clean_dbs :gs_schooldb, :ca, :wy
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
    after do
      clean_dbs :gs_schooldb, :ca
    end
    it 'should find associated school' do
      expect(subject.school).to be_present
      expect(subject.school.id).to eq(school.id)
    end
  end

  describe '#school=' do
    let!(:school) { FactoryGirl.create(:alameda_high_school, id: 1, state: 'CA') }
    subject { FactoryGirl.build(factory, school_id: 999, school_state: 'WY') }
    after do
      clean_dbs :gs_schooldb, :ca, :wy
    end
    it 'should set school_id to the correct value' do
      subject.school = school
      expect(subject.school_id).to eq(school.id)
    end
    it 'should set school_state to the correct value' do
      subject.school = school
      expect(subject.state).to eq(school.state)
    end
  end

end