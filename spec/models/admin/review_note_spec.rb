require 'spec_helper'

describe ReviewNote do

  it { is_expected.to be_a(ReviewNote) }

  describe 'Class' do
    subject { ReviewNote }
    it { is_expected.to respond_to(:active) }
  end

  describe '.active' do
    let!(:first_active) { FactoryGirl.create(:review_note, :active) }
    let!(:first_inactive) { FactoryGirl.create(:review_note, :inactive) }
    let!(:second_active) { FactoryGirl.create(:review_note, :active) }
    after do
      clean_models ReviewNote
    end
    it 'should find only active review notes' do
      expect(ReviewNote.active.size).to eq(2)
      expect(ReviewNote.active.first.id).to eq(first_active.id)
      expect(ReviewNote.active.last.id).to eq(second_active.id)
    end
  end

  describe '#active?' do
    subject { FactoryGirl.create(:review_note, :active) }
    after do
      clean_models ReviewNote
    end
    it { is_expected.to be_active }
    it { is_expected.to_not be_inactive }
  end

  describe '#inactive?' do
    subject { FactoryGirl.create(:review_note, :inactive) }
    after do
      clean_models ReviewNote
    end
    it { is_expected.to be_inactive }
    it { is_expected.to_not be_active }
  end

end