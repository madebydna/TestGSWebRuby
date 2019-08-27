require 'spec_helper'

describe ReviewAnswer do
  it { is_expected.to be_a(ReviewAnswer) }

  after do
    clean_dbs :gs_schooldb
  end

  let(:overall_review) { FactoryBot.build(:five_star_review) }
  let(:teacher_review) { FactoryBot.build(:teacher_effectiveness_review) }
  let(:school) { FactoryBot.build(:school) }
  let(:user) { FactoryBot.build(:user) }
  let(:overall_answer) { FactoryBot.build(:review_answer, review: overall_review, value: 5) }
  let(:teacher_answer) { FactoryBot.build(:review_answer, review: teacher_review) }


  describe '#label' do
    it 'should return value when not for overall topic' do
      expect(teacher_answer.label).to eq(teacher_answer.value)
    end

    it 'should return special label when for overall topic' do
      expect(overall_answer.label).to eq('5 stars')
    end
  end
end
