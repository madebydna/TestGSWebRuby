# frozen_string_literal: true

require 'spec_helper'

describe NewSchoolSubmission do

  context 'grades' do
    let(:new_private_school_submission) { FactoryGirl.build(:new_school_submission, :private_school) }

    it 'cannot be empty' do
      new_private_school_submission.grades = ''
      expect(new_private_school_submission.valid?).to be(false)
    end

    it 'should be a comma-separated string' do
      new_private_school_submission.grades = 'kg 1 5'
      expect(new_private_school_submission.valid?).to be(false)
    end

    it 'must be kg, pk, 1-12, or combination thereof' do
      new_private_school_submission.grades = 'k, pk, 3'
      expect(new_private_school_submission.valid?).to be(false)
    end
  end

  context 'nces code' do
    let(:new_private_school_submission) { FactoryGirl.build(:new_school_submission, :private_school) }
    let(:new_public_school_submission) { FactoryGirl.build(:new_school_submission, :public_school) }

    it 'cannot be empty for k-12 schools' do
      new_private_school_submission.nces_code = nil
      expect(new_private_school_submission.valid?).to be(false)
    end

    it 'must have 12 characters for public or charter schools' do
      new_public_school_submission.nces_code = 12345678
      expect(new_public_school_submission.valid?).to be(false)
    end

    it 'must have 8 characters for private schools' do
      new_private_school_submission.nces_code = 123456789876
      expect(new_private_school_submission.valid?).to be(false)
    end

    it 'is not required for pre-k schools' do
      new_private_school_submission.nces_code = nil
      new_private_school_submission.grades = 'pk'
      expect(new_private_school_submission.valid?).to be(true)
    end
  end

  context 'state_school_id' do
    let (:new_private_school_submission) { FactoryGirl.build(:new_school_submission, :private_school) }

    it 'is required for k-12 schools' do
      new_private_school_submission.state_school_id = nil
      expect(new_private_school_submission.valid?).to be(false)
    end

    it 'is not required for pre-k only schools' do
      # state_school_id was set to nil above
      new_private_school_submission.grades = 'pk'
      expect(new_private_school_submission.valid?).to be(true)
    end
  end

  context 'school_type' do
    let(:new_school_submission) { FactoryGirl.build(:new_school_submission) }

    it 'cannot be empty' do
      expect(new_school_submission.valid?).to be(false)
    end

    it 'must be either private, public, or charter' do
      new_school_submission.school_type = 'private-charter'
      expect(new_school_submission.valid?).to be(false)
    end
  end

  context 'state' do
    let(:new_school_submission) { FactoryGirl.build(:new_school_submission, :public_school) }

    it 'cannot be empty' do
      new_school_submission.state = nil
      expect(new_school_submission.valid?).to be(false)
    end

    it 'must be a state abbreviation' do
      new_school_submission.state = 'california'
      expect(new_school_submission.valid?).to be(false)
    end

    it 'must be one of the 50 U.S. states (or dc)' do
      new_school_submission.state = 'zz'
      expect(new_school_submission.valid?).to be(false)
    end

    it 'accepts dc as a state' do
      new_school_submission.state = 'dc'
      expect(new_school_submission.valid?).to be(true)
    end
  end

  context 'level_code' do
    before(:each) { clean_dbs :gs_schooldb }
    let(:new_school_submission) { FactoryGirl.build(:new_school_submission, :private_school)}

    it 'adds appropriate level code using grades' do
      new_school_submission.level = nil
      new_school_submission.grades = 'kg,6,11'
      new_school_submission.save!
      expect(new_school_submission.level).to eq('e,h,m')
    end
  end

  context 'pre-school only schools' do
    let(:new_school_submission) { FactoryGirl.build(:new_school_submission, :private_school)}

    it 'cannot include a non pre-k grade' do
      expect(new_school_submission.pk_only?).to be(false)
    end
  end
end