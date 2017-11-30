require 'spec_helper'

describe SchoolRouteConcerns do
  subject do
    class FakeClass
      include SchoolRouteConcerns
    end
    FakeClass.new
  end

  describe '#for_new_profile' do
    it 'should return true if new_profile_school == 5' do
      allow(subject).to receive(:new_profile_school).and_return(5)
      expect(subject.for_new_profile?).to be_truthy
    end

    it 'should return false if new_profile_school == 4' do
      allow(subject).to receive(:new_profile_school).and_return(4)
      expect(subject.for_new_profile?).to be_falsey
    end

    it 'should return false if new_profile_school == 3' do
      allow(subject).to receive(:new_profile_school).and_return(3)
      expect(subject.for_new_profile?).to be_falsey
    end

    it 'should return false if new_profile_school == 2' do
      allow(subject).to receive(:new_profile_school).and_return(2)
      expect(subject.for_new_profile?).to be_falsey
    end

    it 'should return false if new_profile_school == 1' do
      allow(subject).to receive(:new_profile_school).and_return(1)
      expect(subject.for_new_profile?).to be_falsey
    end

    it 'should return false if new_profile_school == 0' do
      allow(subject).to receive(:new_profile_school).and_return(0)
      expect(subject.for_new_profile?).to be_falsey
    end

    it 'should return false if new_profile_school is nil' do
      allow(subject).to receive(:new_profile_school).and_return(nil)
      expect(subject.for_new_profile?).to be_falsey
    end
  end
end
