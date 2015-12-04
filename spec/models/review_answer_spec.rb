require 'spec_helper'

describe ReviewAnswer do
  it { is_expected.to be_a(ReviewAnswer) }

  after do
    clean_dbs :gs_schooldb
  end

  let(:overall_review) { FactoryGirl.build(:five_star_review) }
  let(:teacher_review) { FactoryGirl.build(:teacher_effectiveness_review) }
  let(:school) { FactoryGirl.build(:school) }
  let(:user) { FactoryGirl.build(:user) }
  let(:overall_answer) { FactoryGirl.build(:review_answer, review: overall_review, value: 5) }
  let(:teacher_answer) { FactoryGirl.build(:review_answer, review: teacher_review) }


  describe '#label' do
    it 'should return value when not for overall topic' do
      expect(teacher_answer.label).to eq(teacher_answer.value)
    end

    it 'should return special label when for overall topic' do
      expect(overall_answer.label).to eq('5 stars')
    end
  end
end
